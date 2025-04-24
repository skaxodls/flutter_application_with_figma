from flask import Flask, jsonify, request, session, send_from_directory, render_template
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.dialects.mysql import DECIMAL, ENUM
from sqlalchemy import func
from flask import send_from_directory
from werkzeug.security import generate_password_hash
from sqlalchemy.exc import IntegrityError
from flask import request, jsonify
from werkzeug.security import check_password_hash
import os
import base64
from flask_session import Session
from datetime import timedelta,datetime,timezone
from address_classify import classify_address
import requests
from korean_lunar_calendar import KoreanLunarCalendar
from lunardate import LunarDate

from model import detect_and_classify
from werkzeug.utils import secure_filename

app = Flask(__name__)

# ✅ 세션 저장 방식: 'filesystem', 'sqlalchemy', 'redis' 중 선택 가능 (간단하게 filesystem 사용)
app.config['SESSION_TYPE'] = 'filesystem'
# ✅ 세션을 영속적으로 유지할지 여부 설정 (True로 하면 브라우저 꺼도 유지됨)
app.config['SESSION_PERMANENT'] = True
# ✅ 세션 유지 시간 (예: 1일간 유지)
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(days=1)
# ✅ 세션 쿠키에 서명을 추가하여 보안 강화
app.config['SESSION_USE_SIGNER'] = True
# ✅ 파일 기반 세션을 사용할 경우 세션 저장 경로 지정
app.config['SESSION_FILE_DIR'] = './flask_session_files'
# ✅ 세션 암호화를 위한 키 설정 (중요!)
app.secret_key = '1234'

# ✅ Flask 앱에 Session 확장기능 적용
Session(app)

CORS(app, supports_credentials=True)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:0525@127.0.0.1/fishgo'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# 카카오 API 키 설정 (실제 API 키로 변경해야 함)
KAKAO_REST_API_KEY = "d4c06433cf81d2ad087c6bd0381b36d7"
KAKAO_JS_API_KEY = "be680803e7b04c426b6e4b1666b17e67"

# 바다누리 해양정보 서비스 api
SERVICE_KEY = "aPF2881AgVymH7f4Hy61Bg=="


# ----------------------------
# 1) region 테이블 모델
# ----------------------------
class Region(db.Model):
    __tablename__ = 'region'
    region_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    region_name = db.Column(db.String(100), nullable=False)
    detailed_address = db.Column(db.String(255))

    def to_json(self):
        return {
            "region_id": self.region_id,
            "region_name": self.region_name,
            "detailed_address": self.detailed_address
        }

# ----------------------------
# 2) fish 테이블 모델
# ----------------------------
class Fish(db.Model):
    __tablename__ = 'fish'
    fish_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    fish_name = db.Column(db.String(100), nullable=False)
    scientific_name = db.Column(db.String(255))
    morphological_info = db.Column(db.Text)
    taxonomy = db.Column(db.String(100))

    def to_json(self):
        return {
            "fish_id": self.fish_id,
            "fish_name": self.fish_name,
            "scientific_name": self.scientific_name,
            "morphological_info": self.morphological_info,
            "taxonomy": self.taxonomy
        }

# ----------------------------
# 3) members 테이블 모델 (기존 member -> members)
# ----------------------------
class Members(db.Model):
    __tablename__ = 'members'
    uid = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    username = db.Column(db.String(100), nullable=False)
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='SET NULL'))

    region = db.relationship('Region', backref='members', lazy=True)
    
    created_at = db.Column(db.DateTime, server_default=func.current_timestamp())

    def to_json(self):
        return {
            "uid": self.uid,
            "user_id": self.user_id,
            "password_hash": self.password_hash,
            "username": self.username,
            "region_id": self.region_id,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }

# ----------------------------
# 4) fish_region 테이블 모델 (수정됨)
# ----------------------------
class FishRegion(db.Model):
    __tablename__ = 'fish_region'
    fish_region_id = db.Column(db.Integer, primary_key=True, autoincrement=True)  # 물고기지역 고유 ID
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), nullable=False)
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='CASCADE'), nullable=False)

    def to_json(self):
        return {
            "fish_region_id": self.fish_region_id,
            "fish_id": self.fish_id,
            "region_id": self.region_id
        }


# ----------------------------
# 5) posts 테이블 모델
# ----------------------------
class Posts(db.Model):
    __tablename__ = 'posts'
    post_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='CASCADE'), nullable=False)
    title = db.Column(db.String(255), nullable=False)
    content = db.Column(db.Text, nullable=False)
    like_count = db.Column(db.Integer, default=0)
    comment_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, server_default=func.current_timestamp())
    post_status = db.Column(ENUM('판매중', '예약중', '거래완료'), default='판매중')
    #fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), nullable=False)
    price = db.Column(db.Integer, nullable=False)

    def to_json(self):
        return {
            "post_id": self.post_id,
            "uid": self.uid,
            "title": self.title,
            "content": self.content,
            "like_count": self.like_count,
            "comment_count": self.comment_count,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "post_status": self.post_status,
            #"fish_id": self.fish_id,
            "price": self.price
        }

# ----------------------------
# 6) trade 테이블 모델
# ----------------------------
class Trade(db.Model):
    __tablename__ = 'trade'
    trade_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    trade_date = db.Column(db.DateTime, nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.post_id', ondelete='CASCADE'), nullable=False)
    seller_uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='CASCADE'), nullable=False)
    buyer_uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='SET NULL'))
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='SET NULL'))

    def to_json(self):
        return {
            "trade_id": self.trade_id,
            "trade_date": self.trade_date.isoformat() if self.trade_date else None,
            "post_id": self.post_id,
            "seller_uid": self.seller_uid,
            "buyer_uid": self.buyer_uid,
            "region_id": self.region_id
        }

# ----------------------------
# 7) market_price 테이블 모델
# ----------------------------
class MarketPrice(db.Model):
    __tablename__ = 'market_price'
    price_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), nullable=False)
    size_category = db.Column(ENUM('소', '중', '대'), nullable=False)
    min_weight = db.Column(DECIMAL(10, 2), nullable=False)
    max_weight = db.Column(DECIMAL(10, 2), nullable=False)
    price = db.Column(db.Integer, nullable=False)  # 💰 가격 필드 추가

    def to_json(self):
        return {
            "price_id": self.price_id,
            "fish_id": self.fish_id,
            "size_category": self.size_category,
            "min_weight": float(self.min_weight),
            "max_weight": float(self.max_weight),
            "price": self.price
        }

# ----------------------------
# 8) release_criteria 테이블 모델
# ----------------------------
class ReleaseCriteria(db.Model):
    __tablename__ = 'release_criteria'
    release_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), nullable=False)
    min_length = db.Column(DECIMAL(10,2))
    ban_start_date = db.Column(db.Date)
    ban_end_date = db.Column(db.Date)

    def to_json(self):
        return {
            "release_id": self.release_id,
            "fish_id": self.fish_id,
            "min_length": float(self.min_length) if self.min_length is not None else None,
            "ban_start_date": self.ban_start_date.isoformat() if self.ban_start_date else None,
            "ban_end_date": self.ban_end_date.isoformat() if self.ban_end_date else None
        }

# ----------------------------
# 9) fishing_log 테이블 모델
# ----------------------------
class FishingLog(db.Model):
    __tablename__ = 'fishing_log'
    log_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='CASCADE'), nullable=False)
    created_at = db.Column(db.DateTime, server_default=func.current_timestamp())
    fish_length = db.Column(DECIMAL(10,2))
    fish_weight = db.Column(DECIMAL(10,2))
    market_price = db.Column(DECIMAL(10,2))
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), nullable=False)
    uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='CASCADE'), nullable=False)

    def to_json(self):
        return {
            "log_id": self.log_id,
            "region_id": self.region_id,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "fish_length": float(self.fish_length) if self.fish_length is not None else None,
            "fish_weight": float(self.fish_weight) if self.fish_weight is not None else None,
            "market_price": float(self.market_price) if self.market_price is not None else None,
            "fish_id": self.fish_id,
            "uid": self.uid
        }

# ----------------------------
# 10) images 테이블 모델
# ----------------------------
class Images(db.Model):
    __tablename__ = 'images'
    image_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    image_url = db.Column(db.String(255), nullable=False)
    entity_type = db.Column(ENUM('user', 'fish', 'fishing_log', 'post'), nullable=False)
    entity_id = db.Column(db.Integer, nullable=False)

    def to_json(self):
        return {
            "image_id": self.image_id,
            "image_url": self.image_url,
            "entity_type": self.entity_type,
            "entity_id": self.entity_id
        }

# ----------------------------
# 11) likes 테이블 모델
# ----------------------------
class Likes(db.Model):
    __tablename__ = 'likes'
    like_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='CASCADE'), nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.post_id', ondelete='CASCADE'), nullable=False)

    def to_json(self):
        return {
            "like_id": self.like_id,
            "uid": self.uid,
            "post_id": self.post_id
        }

# ----------------------------
# 12) comments 테이블 모델
# ----------------------------
class Comments(db.Model):
    __tablename__ = 'comments'
    comment_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.post_id', ondelete='CASCADE'), nullable=False)
    content = db.Column(db.Text, nullable=False)
    uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='CASCADE'), nullable=False)
    parent_comment_id = db.Column(db.Integer, db.ForeignKey('comments.comment_id', ondelete='CASCADE'))
    created_at = db.Column(db.DateTime, server_default=func.current_timestamp())

    def to_json(self):
        return {
            "comment_id": self.comment_id,
            "post_id": self.post_id,
            "content": self.content,
            "uid": self.uid,
            "parent_comment_id": self.parent_comment_id,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }

# ----------------------------
# 13) personal_fishing_point 테이블 모델
# ----------------------------
class PersonalFishingPoint(db.Model):
    __tablename__ = 'personal_fishing_point'
    fishing_point_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='CASCADE'), nullable=False)
    uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='CASCADE'), nullable=False)

    def to_json(self):
        return {
            "fishing_point_id": self.fishing_point_id,
            "region_id": self.region_id,
            "uid": self.uid
        }

# ----------------------------
# 14) caught_fish 테이블 모델
# ----------------------------
class CaughtFish(db.Model):
    __tablename__ = 'caught_fish'
    uid = db.Column(db.Integer, db.ForeignKey('members.uid', ondelete='CASCADE'), primary_key=True)
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), primary_key=True)
    is_registered = db.Column(db.Boolean, default=False)

    def to_json(self):
        return {
            "uid": self.uid,
            "fish_id": self.fish_id,
            "is_registered": self.is_registered
        }






#도감 페이지에 필요한 API 엔드포인트

@app.route('/api/fishes', methods=['GET'])
def get_fishes():
    """
    간단 요약: 
    물고기 정보+내가 잡은 물고기 싯가총액 반환
    때문에 uid로 여러 테이블 조회함 
    그래서 물고기 정보만 가져오는 api를 따로 만들었음: 
    """
    """
    각 물고기(fish) 별로, 현재 로그인한 사용자가 작성한 fishing_log 테이블에서
    해당 fish_id와 일치하는 로그의 market_price 값을 모두 합산하여
    fish 객체에 price 필드로 추가한 후 JSON 형식으로 반환하는 API 엔드포인트.
    """
    uid = session.get('uid')
    if uid is None:
        return jsonify({"error": "로그인된 사용자가 아닙니다."}), 401

    fishes = Fish.query.all()
    results = []
    for fish in fishes:
        total_price = db.session.query(func.sum(FishingLog.market_price)) \
            .filter(FishingLog.fish_id == fish.fish_id) \
            .filter(FishingLog.uid == uid) \
            .scalar() or 0
        fish_json = fish.to_json()
        fish_json["price"] = int(total_price)
        results.append(fish_json)
    return jsonify(results)


@app.route('/api/all_fish_info', methods=['GET'])
def get_fish_details():
    try:
        fish_list = Fish.query.all()
        for fish in fish_list:
            print(fish.to_json())
            
        return jsonify([fish.to_json() for fish in fish_list]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/caught_fish', methods=['GET'])
def get_caught_fish():
    # 세션에서 uid 가져오기 (simulate_login 에서 uid=1이 저장됨)
    uid = session.get('uid')
    fish_id = request.args.get('fish_id', type=int)
    if uid is None or fish_id is None:
        return jsonify({"error": "uid와 fish_id 파라미터가 필요합니다."}), 400

    caught_fish_list = CaughtFish.query.filter_by(uid=uid, fish_id=fish_id).all()
    return jsonify([cf.to_json() for cf in caught_fish_list])



@app.route('/api/caught_fish', methods=['POST'])
def add_caught_fish():
    data = request.get_json()
    uid = session.get('uid')
    fish_id = data.get('fish_id')
    if not uid or not fish_id:
        return jsonify({"error": "uid와 fish_id가 필요합니다."}), 400

    caught_fish = CaughtFish(uid=uid, fish_id=fish_id)
    db.session.add(caught_fish)
    db.session.commit()

    return jsonify({"message": "물고기 등록 완료"}), 200


@app.route('/api/fish_regions', methods=['GET'])
def get_fish_regions():
    """
    특정 물고기(fish_id)에 해당하는 모든 출몰지역(Region) 정보를 반환합니다.
    GET 파라미터: fish_id
    """
    fish_id = request.args.get('fish_id', type=int)
    if fish_id is None:
        return jsonify({"error": "fish_id 파라미터가 필요합니다."}), 400

    fish_regions = FishRegion.query.filter_by(fish_id=fish_id).all()
    results = []
    for fr in fish_regions:
        # fr.region_id로 Region 정보를 가져옴
        with db.session() as session:
            region = session.get(Region, fr.region_id)  # ✅ SQLAlchemy 2.0 호환 방식

        if region:
            # region 정보(이름, 상세주소) + fish_region_id 등 필요한 정보 결합
            region_data = {
                "fish_region_id": fr.fish_region_id,          # fish_region PK
                "region_id": region.region_id,                # region PK
                "region_name": region.region_name,            # 지역명
                "detailed_address": region.detailed_address,  # 상세주소
            }
            results.append(region_data)
    return jsonify(results)


@app.route('/kakao_map.html')
def kakao_map():
    """
    카카오 지도 검색 페이지 반환
    templates/kakao_map.html 파일을 렌더링하며,
    필요하다면 API 키를 템플릿에 넘길 수 있음
    """
    return render_template('kakao_map.html', api_key=KAKAO_JS_API_KEY)



@app.route('/api/fishing_logs', methods=['POST'])
def create_fishing_log():
    """
    JSON 예시:
    {
      "fish_id": 1,
      "region_name": "용지못 (경남 창원시 성산구 용지동 551-1)",
      "length": "30",
      "weight": "1.2",
      "price": "5000",
      "base64_image": "...",
      "filename": "myfish.jpg"
    }
    """
    data = request.json

    fish_id = data.get('fish_id')
    uid = session.get('uid')
    region_full = data.get('region')  # 예: "용지못 (경남 창원시 성산구 용지동 551-1)"
    length = data.get('length')
    weight = data.get('weight')
    price = data.get('price')
    base64_image = data.get('base64_image')
    filename = data.get('filename') or 'fishing_image.jpg'

    # ✅ region_full을 이름과 주소로 분리
    if '(' in region_full and ')' in region_full:
        try:
            region_name = region_full.split('(')[0].strip()
            detailed_address = region_full.split('(')[1].replace(')', '').strip()
        except Exception:
            region_name = region_full
            detailed_address = ''
    else:
        # 괄호가 없으면 기본값 설정
        region_name = region_full.strip()
        detailed_address = ''

    # 1) region_id 획득
    region_id = get_or_create_region(region_name, detailed_address)
    # 2) fishing_log insert
    new_log = FishingLog(
        region_id=region_id,
        fish_id=fish_id,
        uid=uid,
        fish_length=length if length else 0,
        fish_weight=weight if weight else 0,
        market_price=price if price else 0
    )
    db.session.add(new_log)
    db.session.commit()

    # 3) 이미지 테이블에 추가 (base64_image가 있으면 파일 저장 + DB insert)
    image_url = ""
    if base64_image:
        image_url = save_image_and_insert_table(
            base64_image=base64_image,
            filename=filename,
            entity_type='fishing_log',
            entity_id=new_log.log_id
        )

    return jsonify({
        "message": "fishing_log created",
        "log_id": new_log.log_id,
        "image_url": image_url
    }), 200


# ----------------------------
# 물고기 ID에 따른 기본 이미지 매핑
# ----------------------------
DEFAULT_FISH_IMAGES = {
    1: '/static/images/neobchinongeo.jpg',
    2: '/static/images/nongeo.jpg',
    3: '/static/images/jeomnongeo.jpg',
    4: '/static/images/gamseongdom.jpg',
    5: '/static/images/saenunchi.jpg'
}


@app.route('/api/fishing_logs', methods=['GET'])
def get_fishing_logs():
    uid = session.get('uid')
    fish_id = request.args.get('fish_id', type=int)
    print(f"uid: {uid}, fish_id: {fish_id}")
    # ✅ 로그인하지 않았거나 파라미터가 없는 경우에도 빈 리스트로 처리
    if uid is None or fish_id is None:
        return jsonify([]), 200

    logs = FishingLog.query.filter_by(uid=uid, fish_id=fish_id).all()
    results = []

    for log in logs:
        region = Region.query.get(log.region_id)

        fishing_log_id = getattr(log, 'id', None) or getattr(log, 'log_id', None)
        if fishing_log_id is None:
            continue  # 에러 내지 않고 건너뛰기

        image_obj = Images.query.filter_by(entity_type='fishing_log', entity_id=fishing_log_id).first()
        image_url = (
            image_obj.image_url
            if image_obj
            else DEFAULT_FISH_IMAGES.get(fish_id, "")
        )

        results.append({
            "region_name": region.region_name if region else "",
            "detailed_address": region.detailed_address if region else "",
            "created_at": log.created_at.isoformat() if log.created_at else None,
            "length": str(log.fish_length) if log.fish_length else "0",
            "weight": str(log.fish_weight) if log.fish_weight else "0",
            "price": str(log.market_price) if log.market_price else "0",
            "image_url": image_url
        })
    print(results)

    return jsonify(results)


# ✅ 영어 이름과 fish_id 매핑
fish_id_mapping = {
    "gamseongdom": 4,
    "jeomnongeo": 3,
    "neobchinongeo": 1,
    "nongeo": 2,
    "saenunchi": 5
}

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    image = request.files['image']
    result = detect_and_classify(image)  # ✅ YOLO + Hybrid 모델을 사용한 물고기 종 예측

    if "predicted_class" not in result:
        return jsonify({"error": "Prediction failed"}), 500

    # ✅ 예측된 영어 물고기 종 이름
    english_fish_name = result['predicted_class']
    confidence_score = result["confidence"]

    print(f"예측 결과: {english_fish_name} ({confidence_score:.2f}%)")  # ✅ 터미널에 출력

    # ✅ fish_id 매핑
    fish_id = fish_id_mapping.get(english_fish_name, None)

    if fish_id is None:
        print("매핑된 fish_id 없음")
        return jsonify({"error": "Unknown fish species"}), 500

    print(f"매핑된 fish_id: {fish_id}")  # ✅ 터미널에 출력

    # ✅ 데이터베이스에서 fish_id로 물고기 추가 정보 조회
    fish = Fish.query.filter_by(fish_id=fish_id).first()
    print(f"데이터베이스 조회 결과: {fish}")  # ✅ 터미널에 출력

    if fish:
        fish_info = {
            "scientific_name": fish.scientific_name if hasattr(fish, "scientific_name") else "알 수 없음",
            "morphological_info": fish.morphological_info if hasattr(fish, "morphological_info") else "정보 없음",
            "taxonomy": fish.taxonomy if hasattr(fish, "taxonomy") else "정보 없음"
        }
        fish_name = fish.fish_name if hasattr(fish, "fish_name") else "알 수 없음"
    else:
        fish_info = {
            "scientific_name": "알 수 없음",
            "morphological_info": "정보 없음",
            "taxonomy": "정보 없음"
        }
        fish_name = "알 수 없음"

    print(fish_info)  # ✅ 터미널에 출력

    # ✅ 최종 응답 데이터 구성
    response = {
        "fish_id": fish_id,
        "predicted_class": fish_name,
        "confidence": confidence_score,
        "scientific_name": fish_info["scientific_name"],
        "morphological_info": fish_info["morphological_info"],
        "taxonomy": fish_info["taxonomy"],
    }

    return jsonify(response)


@app.route('/api/market_price', methods=['GET'])
def get_market_prices():
    try:
        market_prices = MarketPrice.query.all()
        for price in market_prices:
            print(price.to_json())
        return jsonify([price.to_json() for price in market_prices]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

#-----------------------------------------------------------
#     커뮤니티 API
#-----------------------------------------------------------

# 홈화면 최신 글 2개
@app.route('/api/posts/latest', methods=['GET'])
def get_latest_posts():
    try:
        posts = Posts.query.order_by(Posts.created_at.desc()).limit(2).all()
        result = []
        for post in posts:
            user = Members.query.get(post.uid)
            region = Region.query.get(user.region_id) if user and user.region_id else None
            image = Images.query.filter_by(entity_type='post', entity_id=post.post_id).first()
            result.append({
                'post_id': post.post_id,
                'title': post.title,
                'location': region.region_name if region else "",
                'created_at': post.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'price': post.price,
                'comment_count': post.comment_count,
                'like_count': post.like_count,
                'image_url': image.image_url if image else "",
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/posts', methods=['POST'])
def create_post():
    if 'uid' not in session:
        return jsonify({'error': '로그인이 필요합니다.'}), 401

    uid = session['uid']
    title = request.form.get('title')
    content = request.form.get('content')
    price = int(request.form.get('price', 0))
    status = request.form.get('status', '판매중')
    image_file = request.files.get('images')  # ✅ 없어도 괜찮음

    if not title or not content:
        return jsonify({'error': '제목과 내용을 입력해주세요.'}), 400

    try:
        # 1. 게시글 생성
        new_post = Posts(
            uid=uid,
            title=title,
            content=content,
            price=price,
            post_status=status,
            like_count=0,
            comment_count=0
        )
        db.session.add(new_post)
        db.session.commit()

        # 2. 이미지 저장 (선택)
        image_url = ""
        if image_file:
            filename = secure_filename(image_file.filename)
           
            image_path = os.path.join('static', 'images', filename)
            image_file.save(image_path)

            image_url = f'/static/images/{filename}'

            new_image = Images(
                image_url=image_url,
                entity_type='post',
                entity_id=new_post.post_id
            )
            db.session.add(new_image)
            db.session.commit()

        return jsonify({
            'message': '게시글 등록 완료',
            'post_id': new_post.post_id,
            'image_url': image_url  # "" 일 수도 있음
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'게시글 작성 중 오류: {str(e)}'}), 500




@app.route('/api/posts', methods=['GET'])
def get_all_posts():
    try:
        posts = Posts.query.order_by(Posts.created_at.desc()).all()
        post_list = []

        for post in posts:
            user = Members.query.get(post.uid)
            region = Region.query.get(user.region_id) if user and user.region_id else None

            image = Images.query.filter_by(entity_type='post', entity_id=post.post_id).first()
            image_url = image.image_url if image else ""

            post_list.append({
                'post_id': post.post_id,
                'title': post.title,
                'content': post.content,
                'uid': post.uid,
                'username': user.username if user else "Unknown",
                'location': region.region_name if region else "",
                'created_at': post.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'status': post.post_status,
                'like_count': post.like_count,
                'comment_count': post.comment_count,
                'price': post.price,
                'image_url': image_url
            })
            

        
        return jsonify(post_list), 200

    except Exception as e:
        return jsonify({'error': f'서버 오류: {str(e)}'}), 500

# 게시글 수정
@app.route('/api/posts/<int:post_id>', methods=['PUT'])
def update_post(post_id):
    if 'uid' not in session:
        return jsonify({'error': '로그인이 필요합니다.'}), 401

    uid = session['uid']
    data = request.get_json()

    title = data.get('title')
    content = data.get('content')
    price = data.get('price')
    status = data.get('status')
    image_file = request.files.get('images')

    post = Posts.query.get(post_id)
    if not post:
        return jsonify({'error': '게시글이 존재하지 않습니다.'}), 404

    if post.uid != uid:
        return jsonify({'error': '권한이 없습니다.'}), 403

    try:
        post.title = title
        post.content = content
        post.price = price
        post.post_status = status
        db.session.commit()

        if image_file:
            filename = secure_filename(image_file.filename)
            image_bytes = image_file.read()
            base64_image = base64.b64encode(image_bytes).decode('utf-8')

            # 기존 이미지 삭제는 선택적으로 구현할 수 있음
            image_url = save_image_and_insert_table(
                base64_image=base64_image,
                filename=filename,
                entity_type='post',
                entity_id=post.post_id
            )

        return jsonify({'message': '게시글 수정 완료'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'수정 중 오류 발생: {str(e)}'}), 500

#게시글 삭제
@app.route('/api/posts/<int:post_id>', methods=['DELETE'])
def delete_post(post_id):
    if 'uid' not in session:
        return jsonify({'error': '로그인이 필요합니다.'}), 401

    uid = session['uid']
    post = Posts.query.get(post_id)

    if not post:
        return jsonify({'error': '게시글이 존재하지 않습니다.'}), 404

    if post.uid != uid:
        return jsonify({'error': '권한이 없습니다.'}), 403

    try:
        # 1. 이미지 먼저 삭제
        Images.query.filter_by(entity_type='post', entity_id=post_id).delete()

        # 2. 댓글도 삭제
        Comments.query.filter_by(post_id=post_id).delete()

        # 3. 게시글 삭제
        db.session.delete(post)
        db.session.commit()
        return jsonify({'message': '게시글 삭제 완료'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'삭제 중 오류 발생: {str(e)}'}), 500

# 댓글

@app.route('/api/posts/<int:post_id>/comments', methods=['GET'])
def get_comments(post_id):
    try:
        comments = Comments.query.filter_by(post_id=post_id).order_by(Comments.created_at.asc()).all()
        comment_list = []

        for comment in comments:
            user = Members.query.get(comment.uid)

            comment_list.append({
                'comment_id': comment.comment_id,
                'uid': comment.uid,
                'username': user.username if user else '알 수 없음',
                'content': comment.content,
                'created_at': comment.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'parent_comment_id': comment.parent_comment_id
            })

        return jsonify(comment_list), 200

    except Exception as e:
        return jsonify({'error': f'댓글 조회 중 오류: {str(e)}'}), 500



@app.route('/api/posts/<int:post_id>/comments', methods=['POST'])
def create_comment(post_id):
    if 'uid' not in session:
        return jsonify({'error': '로그인이 필요합니다.'}), 401

    uid = session['uid']
    data = request.get_json()

    content = data.get('content')
    parent_id = data.get('parent_comment_id')  # 대댓글을 위한 필드 (없으면 None)

    if not content:
        return jsonify({'error': '댓글 내용을 입력해주세요.'}), 400

    try:
        new_comment = Comments(
            post_id=post_id,
            uid=uid,
            content=content,
            parent_comment_id=parent_id  # None이면 일반 댓글
        )
        db.session.add(new_comment)

        # 게시글의 댓글 수 증가
        post = Posts.query.get(post_id)
        if post:
            post.comment_count += 1

        db.session.commit()

        return jsonify({'message': '댓글 등록 완료'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'댓글 등록 중 오류: {str(e)}'}), 500




@app.route('/api/comments/<int:comment_id>', methods=['DELETE'])
def delete_comment(comment_id):
    if 'uid' not in session:
        return jsonify({'error': '로그인이 필요합니다.'}), 401

    uid = session['uid']
    comment = Comments.query.get(comment_id)

    if not comment:
        return jsonify({'error': '댓글이 존재하지 않습니다.'}), 404

    if comment.uid != uid:
        return jsonify({'error': '삭제 권한이 없습니다.'}), 403

    try:
        db.session.delete(comment)

        # 게시글 댓글 수 감소
        post = Posts.query.get(comment.post_id)
        if post:
            post.comment_count = max(post.comment_count - 1, 0)

        db.session.commit()
        return jsonify({'message': '댓글 삭제 완료'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'댓글 삭제 중 오류: {str(e)}'}), 500



# ──────────────────────────────
# API 엔드포인트: 거래 데이터 목록 반환 (/api/trades)
# ──────────────────────────────

@app.route('/api/trades', methods=['POST'])
def create_trade():
    if 'uid' not in session:
        return jsonify({'error': '로그인이 필요합니다.'}), 401

    seller_uid = session['uid']
    data = request.get_json()

    post_id = data.get('post_id')
    buyer_uid = data.get('buyer_uid')
    date_str = data.get('trade_date')  # "2025-04-10 14:30"
    region_name = data.get('region_name')
    detailed_address = data.get('detailed_address')

    if not all([post_id, buyer_uid, date_str, region_name, detailed_address]):
        return jsonify({'error': '필수 항목 누락'}), 400

    try:
        # 1. 날짜/시간 문자열을 datetime 객체로 파싱
        trade_date = datetime.strptime(date_str, "%Y-%m-%d %H:%M")

        # 2. Region 저장
        new_region = Region(region_name=region_name, detailed_address=detailed_address)
        db.session.add(new_region)
        db.session.commit()

        # 3. Trade 저장
        new_trade = Trade(
            post_id=post_id,
            seller_uid=seller_uid,
            buyer_uid=buyer_uid,
            trade_date=trade_date,
            region_id=new_region.region_id
        )
        db.session.add(new_trade)

        # ✅ 4. 해당 게시글 상태를 '예약중'으로 변경
        post = Posts.query.get(post_id)
        if post:
            post.post_status = '예약중'
        db.session.commit()

        return jsonify({'message': '거래 등록 완료'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'거래 등록 중 오류 발생: {str(e)}'}), 500
    
@app.route('/api/trades', methods=['GET'])
def get_trades():
    uid = session.get('uid')
    if uid is None:
        return jsonify({"error": "로그인이 필요합니다."}), 401

    trades = Trade.query.filter(
        (Trade.seller_uid == uid) | (Trade.buyer_uid == uid)
    ).all()

    result = []
    for trade in trades:
        post = Posts.query.get(trade.post_id)
        region = Region.query.get(trade.region_id) if trade.region_id else None
        buyer = Members.query.get(trade.buyer_uid) if trade.buyer_uid else None
        seller = Members.query.get(trade.seller_uid) if trade.seller_uid else None

        result.append({
            "trade_id": trade.trade_id,
            "post_id": trade.post_id,  # post_id 추가
            "trade_date": trade.trade_date.strftime("%Y-%m-%d") if trade.trade_date else None,
            "time": trade.trade_date.strftime("%H시 %M분") if trade.trade_date else "",
            "address": (region.detailed_address if region and region.detailed_address 
                        else (region.region_name if region else "")),
            "title": post.title if post else "",
            "price": post.price if post else None,
            "post_status": post.post_status if post else "",
            "seller_name": seller.username if seller else "",
            "buyer_name": buyer.username if buyer else "",
            "is_seller": trade.seller_uid == uid  # 판매자 여부
        })
    
    return jsonify(result)


# ──────────────────────────────
# trade_calendar_screen.dart 구매확정 버튼 액션
# ──────────────────────────────
@app.route('/api/confirm_purchase', methods=['POST'])
def confirm_purchase():
    uid = session.get('uid')
    if uid is None:
        return jsonify({"error": "로그인이 필요합니다."}), 401

    data = request.get_json()
    post_id = data.get('post_id')
    if post_id is None:
        return jsonify({"error": "post_id가 필요합니다."}), 400

    post = Posts.query.get(post_id)
    if not post:
        return jsonify({"error": "게시글이 존재하지 않습니다."}), 404

    # 구매자임을 확인하는 추가 검증 로직을 넣을 수 있음

    post.post_status = '거래완료'
    db.session.commit()
    return jsonify({"message": "구매확정이 완료되었습니다."})

# ──────────────────────────────
# 거래 삭제 API 엔드포인트 (/api/delete_trade)
# ──────────────────────────────
@app.route('/api/delete_trade', methods=['POST'])
def delete_trade():
    uid = session.get('uid')
    if uid is None:
        return jsonify({"error": "로그인이 필요합니다."}), 401

    data = request.get_json()
    trade_id = data.get('trade_id')
    post_id = data.get('post_id')
    
    if trade_id is None or post_id is None:
        return jsonify({"error": "trade_id와 post_id가 필요합니다."}), 400

    trade = Trade.query.get(trade_id)
    if not trade:
        return jsonify({"error": "해당 거래가 존재하지 않습니다."}), 404

    # post_id에 해당하는 게시글의 상태를 '판매중'으로 업데이트
    post = Posts.query.get(post_id)
    if post:
        post.post_status = '판매중'
    
    # 거래 튜플 삭제
    db.session.delete(trade)
    db.session.commit()

    return jsonify({"message": "거래가 삭제되었습니다."})

@app.route('/api/trade_history', methods=['GET'])
def get_trades_history():
    uid = session.get('uid')
    if uid is None:
        return jsonify({"error": "로그인이 필요합니다."}), 401

    # 현재 uid와 seller_uid 또는 buyer_uid가 일치하는 모든 거래 조회
    trades = Trade.query.filter(
        (Trade.seller_uid == uid) | (Trade.buyer_uid == uid)
    ).all()

    # 세 그룹으로 분리할 리스트 (판매중, 판매완료, 구매완료)
    selling_items = []            # 판매중: seller이고, post_status가 '판매중' 또는 '예약중'
    selling_completed_items = []  # 판매완료: seller이고, post_status가 '거래완료'
    purchased_items = []          # 구매완료: buyer이고, post_status가 '거래완료'

    for trade in trades:
        post = Posts.query.get(trade.post_id)
        if not post:
            continue

        # 이미지 조회: images 테이블에서 entity_type='post' 및 entity_id가 post.post_id와 일치하는 이미지 가져오기
        image_obj = Images.query.filter_by(entity_type='post', entity_id=post.post_id).first()
        image_url = image_obj.image_url if image_obj else None

        post_data = {
            "trade_id": trade.trade_id,
            "trade_date": trade.trade_date.strftime("%Y-%m-%d %H:%M"),
            "post_id": trade.post_id,
            "title": post.title,
            "price": post.price,
            "post_status": post.post_status,
            "seller_uid": trade.seller_uid,
            "buyer_uid": trade.buyer_uid,
            "image_url": image_url  # 이미지 URL 추가
        }
        

        # 판매자인 경우
        if trade.seller_uid == uid:
            if post.post_status in ['판매중', '예약중']:
                selling_items.append(post_data)
            elif post.post_status == '거래완료':
                selling_completed_items.append(post_data)

        # 구매자인 경우 (post_status가 '거래완료'인 경우만 구매완료로 표시)
        if trade.buyer_uid == uid and post.post_status == '거래완료':
            purchased_items.append(post_data)

    return jsonify({
        "sellingItems": selling_items,               # 판매중 탭 데이터
        "sellingCompletedItems": selling_completed_items,  # 판매완료 탭 데이터
        "purchasedItems": purchased_items              # 구매완료 탭 데이터
    })


@app.route('/api/my_posts', methods=['GET'])
def get_my_posts():
    uid = session.get('uid')
    if uid is None:
        return jsonify({"error": "로그인이 필요합니다."}), 401

    one_week_ago = datetime.now(timezone.utc) - timedelta(days=7)
    # 현재 uid의 사용자가 작성한 글 중 최근 1주일 이내에 작성된 글을 가져옵니다.
    posts = Posts.query.filter(
        Posts.uid == uid,
        Posts.created_at >= one_week_ago
    ).order_by(Posts.created_at.desc()).all()

    result = []
    for post in posts:
        result.append({
            "post_id": post.post_id,
            "title": post.title,
            "created_at": post.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "price": post.price,
            # 이미지 URL은 이미지 테이블이나 별도의 로직을 통해 가져올 수 있습니다.
            # 예시로 아래와 같이 post_id를 기준으로 이미지 URL을 조회하는 함수를 사용했다고 가정합니다.
            "image_url": get_image_url_for_post(post.post_id)
        })
    return jsonify(result)


#-----------------------------------------------------------
#     지역별 게시글 조회 API
#-----------------------------------------------------------

@app.route('/api/posts_by_region', methods=['GET'])
def posts_by_region():
    # 세션에 저장된 uid 확인
    if 'uid' not in session:
        return jsonify({"error": "User not logged in"}), 401

    user_uid = session.get('uid')
    # SQLAlchemy 2.0 방식 사용: db.session.get(Model, primary_key)
    member = db.session.get(Members, user_uid)
    if not member:
        return jsonify({"error": "Member not found"}), 404

    if not member.region_id:
        return jsonify({"error": "User region not set"}), 400

    # 회원의 region_id를 이용해 Region 테이블에서 상세주소 조회
    user_region_obj = db.session.get(Region, member.region_id)
    if not user_region_obj or not user_region_obj.detailed_address:
        return jsonify({"error": "User region detail not found"}), 404

    # 사용자의 상세주소를 classify_address로 처리하여 region 문자열 도출
    user_region = classify_address(user_region_obj.detailed_address)
    print(user_region)
    if not user_region:
        return jsonify({"error": "Could not determine region from user's detail address"}), 400

    # Posts 테이블은 region_id가 없으므로, 작성자(Members)와 Region을 join하여 가져옴
    results = db.session.query(Posts, Members, Region) \
        .join(Members, Posts.uid == Members.uid) \
        .join(Region, Members.region_id == Region.region_id) \
        .all()

    filtered_posts = []
    for post, post_member, post_region in results:
        # 게시글 작성자의 Region의 상세주소를 classify_address로 처리하여 region 문자열 도출
        post_region_str = classify_address(post_region.detailed_address)
        if post_region_str == user_region:
            post_data = post.to_json()
            # Region 테이블의 region_name 추가
            post_data["region_name"] = post_region.region_name
            # Images 테이블에서 해당 게시글의 이미지들을 entity_type과 entity_id 조건으로 조회
            images = db.session.query(Images).filter_by(entity_type='post', entity_id=post.post_id).all()
            post_data["images"] = [img.to_json() for img in images]
            filtered_posts.append(post_data)

    return jsonify({
        "user_region": user_region,
        "posts": filtered_posts
    })


@app.route('/api/fishing_points', methods=['GET'])
def get_fishing_points():
    # Flask 세션에서 int 타입으로 저장된 uid를 가져옴
    uid = session.get('uid')
    if uid is None:
        return jsonify({'error': 'User not logged in'}), 401

    # ORM 방식으로 PersonalFishingPoint와 Region을 join 하여 uid에 해당하는 데이터를 조회
    results = db.session.query(PersonalFishingPoint, Region) \
        .join(Region, PersonalFishingPoint.region_id == Region.region_id) \
        .filter(PersonalFishingPoint.uid == uid) \
        .all()

    # 조회된 결과를 리스트 형태의 딕셔너리로 변환
    points = []
    for pf, region in results:
        points.append({
            'region_name': region.region_name,
            'detailed_address': region.detailed_address
        })

    return jsonify(points)


# personal_fishing_point 저장 API 엔드포인트
@app.route('/api/personal_fishing_point', methods=['POST'])
def create_personal_fishing_point():
    data = request.json
    # JSON 예시: {"region": "용지못 (경남 창원시 성산구 용지동 551-1)"}
    region_full = data.get("region")
    if not region_full:
        return jsonify({"error": "region is required"}), 400

    # region_full 문자열을 region_name과 detailed_address로 분리
    if '(' in region_full and ')' in region_full:
        try:
            region_name = region_full.split('(')[0].strip()
            detailed_address = region_full.split('(')[1].replace(')', '').strip()
        except Exception:
            region_name = region_full.strip()
            detailed_address = ''
    else:
        region_name = region_full.strip()
        detailed_address = ''

    # 세션에서 uid 가져오기
    uid = session.get("uid")
    if uid is None:
        return jsonify({"error": "User not logged in"}), 401

    # region 정보 가져오기 또는 생성하기
    region_id = get_or_create_region(region_name, detailed_address)

    # personal_fishing_point에 새로운 행 삽입
    new_point = PersonalFishingPoint(region_id=region_id, uid=uid)
    db.session.add(new_point)
    db.session.commit()

    return jsonify({
        "message": "personal_fishing_point created",
        "fishing_point_id": new_point.fishing_point_id
    }), 200
    
    

@app.route('/api/personal_fishing_point', methods=['DELETE'])
def delete_personal_fishing_point():
    data = request.json
    region_full = data.get("region")
    if not region_full:
        return jsonify({"error": "region is required"}), 400

    # region_full 형식: "region_name (detailed_address)"
    if '(' in region_full and ')' in region_full:
        try:
            region_name = region_full.split('(')[0].strip()
            detailed_address = region_full.split('(')[1].replace(')', '').strip()
        except Exception:
            region_name = region_full.strip()
            detailed_address = ''
    else:
        region_name = region_full.strip()
        detailed_address = ''

    uid = session.get("uid")
    if uid is None:
        return jsonify({"error": "User not logged in"}), 401

    # region 테이블에서 해당 지역 조회
    region = Region.query.filter_by(region_name=region_name, detailed_address=detailed_address).first()
    if not region:
        return jsonify({"error": "Region not found"}), 404

    # uid와 region_id로 personal_fishing_point 조회
    point = PersonalFishingPoint.query.filter_by(region_id=region.region_id, uid=uid).first()
    if not point:
        return jsonify({"error": "Personal fishing point not found"}), 404

    db.session.delete(point)
    db.session.commit()
    return jsonify({"message": "Personal fishing point deleted"}), 200



# 음력 1일 ~ 30일에 따른 물때식 매핑 (첨부해주신 표를 반영)
TIDE_MAP = {
    1: "턱사리", 2: "한사리", 3: "목사리", 4: "어깨사리", 5: "허리사리",
    6: "한꺽기", 7: "두꺽기", 8: "선조금", 9: "앉은조금", 10: "한조금",
    11: "한매", 12: "두매", 13: "무릅사리", 14: "배꼼사리", 15: "가슴사리",
    16: "턱사리", 17: "한사리", 18: "목사리", 19: "어깨사리", 20: "허리사리",
    21: "한꺽기", 22: "두꺽기", 23: "선조금", 24: "앉은조금", 25: "한조금",
    26: "한매", 27: "두매", 28: "무릅사리", 29: "배꼽사리", 30: "가슴사리",
}


@app.route('/api/tide_combined', methods=['GET'])
def get_tide_combined():
    obs_code = request.args.get('obsCode', 'DT_0001')
    date = request.args.get('date')
    if not date:
        date = datetime.now().strftime('%Y%m%d')
    
    url_past = (
        "http://www.khoa.go.kr/api/oceangrid/tideObsPreTab/search.do"
        f"?ServiceKey={SERVICE_KEY}"
        f"&ObsCode={obs_code}"
        f"&Date={date}"
        "&ResultType=json"
    )
    
    url_recent = (
        "http://www.khoa.go.kr/api/oceangrid/tideObsRecent/search.do"
        f"?ServiceKey={SERVICE_KEY}"
        f"&ObsCode={obs_code}"
        "&ResultType=json"
    )
    
    try:
        resp_past = requests.get(url_past)
        resp_past.raise_for_status()
        data_past = resp_past.json()
        
        resp_recent = requests.get(url_recent)
        resp_recent.raise_for_status()
        data_recent = resp_recent.json()
        
        # 음력 날짜 계산 (한국 음력)
        today = datetime.now()
        calendar = KoreanLunarCalendar()
        calendar.setSolarDate(today.year, today.month, today.day)
        lunar_year = calendar.lunarYear
        lunar_month = calendar.lunarMonth
        lunar_day = calendar.lunarDay
        
        # 음력 1~30 범위 보정 (음력은 보통 1~30일)
        if lunar_day < 1:
            lunar_day = 1
        elif lunar_day > 30:
            lunar_day = 30
        
        # 음력 일자에 따른 물때식 결정 (첨부해주신 표를 사용)
        tide_info = TIDE_MAP.get(lunar_day, "정보 없음")
        
        combined = {
            "past": data_past,
            "recent": data_recent,
            "lunar_info": {
                "lunar_year": lunar_year,
                "lunar_month": lunar_month,
                "lunar_day": lunar_day,
                "tide_info": tide_info
            }
        }
        print(f"Combined data: {combined}")
        return jsonify(combined)
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500



@app.route('/api/tide-info', methods=['GET'])
def get_tide_info():
    today = datetime.now()

    # 음력으로 변환 (lunardate 사용)
    lunar_today = LunarDate.fromSolarDate(today.year, today.month, today.day)

    lunar_month = lunar_today.month
    lunar_day = lunar_today.day

    tide_name = TIDE_MAP.get(lunar_day, "알 수 없음")

    # 응답 데이터 구성
    tide_info = f"{today.strftime('%m.%d')}(음 {lunar_month:02d}.{lunar_day:02d}) {tide_name}"

    return jsonify({"tide_info": tide_info})

#로그인된 마이페이지에서 내가 작성한 글에서 바로 게시글로 가는 api
@app.route('/api/posts/<int:post_id>', methods=['GET'])
def get_post_detail(post_id):
    try:
        post = Posts.query.get(post_id)
        if not post:
            return jsonify({'error': '게시글을 찾을 수 없습니다.'}), 404

        user = Members.query.get(post.uid)
        region = Region.query.get(user.region_id) if user and user.region_id else None

        image = Images.query.filter_by(entity_type='post', entity_id=post.post_id).first()
        image_url = image.image_url if image else ""

        # status에 따른 tagColor 설정 (Flutter _statusColor와 동일한 기준)
        status = post.post_status
        if status == '예약중':
            tagColor = "#4A68EA"
        elif status == '거래완료':
            tagColor = "#000000"
        else:
            tagColor = "#808080"  # 기본 회색

        current_user_uid = session.get('uid')

        result = {
            'post_id': post.post_id,
            'title': post.title,
            'content': post.content,
            'uid': post.uid,
            'username': user.username if user else "Unknown",
            'location': region.region_name if region else "",
            'created_at': post.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'status': status,
            'like_count': 0,  # like는 0으로 고정
            'comment_count': post.comment_count,
            'price': post.price,
            'image_url': image_url,
            'tagColor': tagColor,
            'currentUserUid': current_user_uid,
            'userRegion': region.region_name if region else ""
        }
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': f'서버 오류: {str(e)}'}), 500


#---------------------------
#함수
#---------------------------

def get_image_url_for_post(post_id):
    """
    낚시 로그 ID를 기반으로 이미지를 가져오고, 없으면 기본 자산 이미지를 반환한다.
    """
    images = Images.query.filter_by(entity_type='post', entity_id=post_id).all()
    print(f"Found images: {images}")
    
    if images:  
        # post와 연관된 이미지가 있는 경우
        return [
            {
                "image_url": image.image_url,
                "image_download_url": f"/api/images/{image.image_url}"
            } for image in images
        ]
    
    # 이미지가 없는 경우, 기본 자산 이미지 경로를 반환
    default_asset_path = "assets/icons/fish_icon1.png"
    return [
        {
            "image_url": default_asset_path,
            "image_download_url": ""
        }
    ]





def get_images_for_fishing_log(log_id, fish_id):
    """
    낚시 로그 ID를 기반으로 이미지를 가져오고, 없으면 해당 물고기 ID의 기본 이미지를 반환한다.
    """
    images = Images.query.filter_by(entity_type='fishing_log', entity_id=log_id).all()
    
    if images:  
        # 낚시 로그에 이미지가 있는 경우
        return [
            {
                "image_url": image.image_url,
                "image_download_url": f"/api/images/{image.image_url}"
            } for image in images
        ]
    
    # 낚시 로그에 이미지가 없으면, 물고기 ID의 기본 이미지 제공
    default_image_url = DEFAULT_FISH_IMAGES.get(fish_id, "")
    return [
        {
            "image_url": default_image_url,
            "image_download_url": f"/api/images/{os.path.basename(default_image_url)}"
        }
    ] if default_image_url else []

def get_or_create_region(region_name, detailed_address):
    """region 테이블에서 동일 레코드가 있으면 반환, 없으면 생성 후 반환."""
    region = Region.query.filter_by(
        region_name=region_name,
        detailed_address=detailed_address
    ).first()

    if not region:
        region = Region(
            region_name=region_name,
            detailed_address=detailed_address
        )
        db.session.add(region)
        db.session.commit()
    return region.region_id


def save_image_and_insert_table(base64_image, filename, entity_type, entity_id):
    """
    base64 디코딩하여 서버에 이미지 파일 저장,
    images 테이블에 레코드 추가 후 image_url 반환
    """
    # 저장 디렉토리: 현재 작업 디렉토리의 "static/images" 폴더
    save_dir = os.path.join('.', 'static', 'images')
    os.makedirs(save_dir, exist_ok=True)

    # 파일 경로
    save_path = os.path.join(save_dir, filename)


    # base64 디코딩
    with open(save_path, 'wb') as f:
        f.write(base64.b64decode(base64_image))

    # 접근 URL (서버 주소 + /static/fishing_log_images/filename)
    image_url = f'/static/images/{filename}'

    # images 테이블 insert
    new_image = Images(
        image_url=image_url,
        entity_type=entity_type,
        entity_id=entity_id
    )
    db.session.add(new_image)
    db.session.commit()

    return image_url

@app.route('/kakao_postcode.html')
def serve_html():
    return send_from_directory('templates', 'kakao_postcode.html')

# ----------------------------
# 회원가입 API
# ----------------------------
@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    user_id = data.get('id')
    password = data.get('password')
    username = data.get('username')
    # region_name = data.get('location')
    region_name = data.get('region_name')
    detailed_address = data.get('detailed_address')
    
    if not user_id or not password or not username or not region_name:
        return jsonify({"error": "모든 필드를 입력해주세요."}), 400

    existing_user = Members.query.filter_by(user_id=user_id).first()
    if existing_user:
        return jsonify({"error": "이미 존재하는 아이디입니다."}), 400

    region = Region.query.filter_by(region_name=region_name, detailed_address=detailed_address).first()
    if not region:
        region = Region(region_name=region_name, detailed_address=detailed_address)
        db.session.add(region)
        db.session.commit()

    hashed_pw = generate_password_hash(password)
    new_member = Members(
        user_id=user_id,
        password_hash=hashed_pw,
        username=username,
        region_id=region.region_id
    )
    db.session.add(new_member)
    db.session.commit()

    return jsonify({"message": "회원가입 성공"}), 200

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()

    user_id = data.get('id')
    password = data.get('password')

    if not user_id or not password:
        return jsonify({"error": "아이디와 비밀번호를 모두 입력해주세요."}), 400

    user = Members.query.filter_by(user_id=user_id).first()

    if user is None:
        return jsonify({"error": "존재하지 않는 사용자입니다."}), 401

    # 🔐 비밀번호 확인
    if not check_password_hash(user.password_hash, password):
        return jsonify({"error": "비밀번호가 올바르지 않습니다."}), 401

    # ✅ 로그인 성공
    session['uid'] = user.uid  # 세션 저장 (선택 사항)
    
    
    # 🔹 현재 세션 정보 출력 (터미널 확인용)
    print("🔹 현재 세션 정보:", dict(session))
    
    return jsonify({
        "message": "로그인 성공",
        "uid": user.uid,
        "username": user.username,
        "region_id": user.region_id
    }), 200

@app.route('/api/me', methods=['GET'])
def get_me():
    uid = session.get('uid')
    if not uid:
        return jsonify({"error": "로그인되지 않았습니다."}), 401

    user = Members.query.get(uid)
    if not user:
        return jsonify({"error": "사용자를 찾을 수 없습니다."}), 404

    return jsonify(user.to_json()), 200


@app.route('/api/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({"message": "로그아웃 완료"}), 200


@app.route('/api/check_session', methods=['GET'])
def check_session():
    uid = session.get('uid')
    if uid:
        user = Members.query.get(uid)
        return jsonify({
            "logged_in": True,
            "uid": uid,
            "username": user.username,
            "region_id": user.region_id
        }), 200
    return jsonify({"logged_in": False}), 200


@app.route('/api/user_profile', methods=['GET'])
def get_user_profile():
    uid = session.get('uid')
    if not uid:
        return jsonify({"error": "로그인되지 않음"}), 401

    user = Members.query.get(uid)
    region = Region.query.get(user.region_id)
    
    print(user.to_json())

    return jsonify({
        "user_id": user.user_id,
        "username": user.username,
        "region": region.region_name if region else "알 수 없음",
        "uid": user.uid
    }), 200


@app.route('/api/session', methods=['GET'])
def check_session_status():
    uid = session.get('uid')
    return jsonify({"loggedIn": bool(uid)})


# ----------------------------
# 애플리케이션 시작
# ----------------------------
if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # 테이블 생성 (이미 존재하면 영향 없음)
    app.run(debug=True, host='0.0.0.0', port=8080)
