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

from model import detect_and_classify

app = Flask(__name__)
app.secret_key = "1234"  # 세션 암호화를 위한 비밀키 설정
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:0525@127.0.0.1/fishgo'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# 카카오 API 키 설정 (실제 API 키로 변경해야 함)
KAKAO_REST_API_KEY = "d4c06433cf81d2ad087c6bd0381b36d7"
KAKAO_JS_API_KEY = "be680803e7b04c426b6e4b1666b17e67"

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
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), nullable=False)

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
            "fish_id": self.fish_id
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
    min_weight = db.Column(DECIMAL(10,2), nullable=False)
    max_weight = db.Column(DECIMAL(10,2), nullable=False)

    def to_json(self):
        return {
            "price_id": self.price_id,
            "fish_id": self.fish_id,
            "size_category": self.size_category,
            "min_weight": float(self.min_weight),
            "max_weight": float(self.max_weight)
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



#로그인했다고 가정
@app.before_request
def simulate_login():
    # 모든 요청 전에 세션에 uid=1 (user1) 저장하여 로그인 상태로 가정
    session['uid'] = 1




#도감 페이지에 필요한 API 엔드포인트

@app.route('/api/fishes', methods=['GET'])
def get_fishes():
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
    uid = data.get('uid')
    fish_id = data.get('fish_id')
    if not uid or not fish_id:
        return jsonify({"error": "uid와 fish_id가 필요합니다."}), 400

    caught_fish = CaughtFish(uid=uid, fish_id=fish_id)
    db.session.add(caught_fish)
    db.session.commit()

    return jsonify({"message": "잡은 물고기 등록 완료"}), 200


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
      "uid": 1,
      "region_name": "서울특별시",
      "detailed_address": "중구 청파로 123",
      "length": "30",
      "weight": "1.2",
      "price": "5000",
      "base64_image": "...",
      "filename": "myfish.jpg"
    }
    """
    data = request.json

    fish_id = data.get('fish_id')
    uid = data.get('uid')
    region_name = data.get('region_name')
    detailed_address = data.get('detailed_address')
    length = data.get('length')
    weight = data.get('weight')
    price = data.get('price')
    base64_image = data.get('base64_image')
    filename = data.get('filename') or 'fishing_image.jpg'

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
    uid = request.args.get('uid', type=int)
    fish_id = request.args.get('fish_id', type=int)
    
    if uid is None or fish_id is None:
        return jsonify({"error": "uid와 fish_id 파라미터가 필요합니다."}), 400

    logs = FishingLog.query.filter_by(uid=uid, fish_id=fish_id).all()
    results = []
    
    for log in logs:
        region = Region.query.get(log.region_id)

        # FishingLog의 기본 키 확인
        fishing_log_id = getattr(log, 'id', None) or getattr(log, 'log_id', None)
        if fishing_log_id is None:
            return jsonify({"error": "FishingLog 모델에서 id 또는 log_id를 찾을 수 없습니다."}), 500

        # 낚시 로그 ID에 해당하는 이미지 중 첫 번째 이미지만 조회
        image_obj = Images.query.filter_by(entity_type='fishing_log', entity_id=fishing_log_id).first()
        
        if image_obj:
            # 낚시 로그에 이미지가 있는 경우 → 첫 번째 이미지의 경로
            image_url = image_obj.image_url
        else:
            # 낚시 로그에 이미지가 없으면, 물고기 ID의 기본 이미지 제공
            default_image_filename = DEFAULT_FISH_IMAGES.get(fish_id, "")
            image_url = default_image_filename if default_image_filename else ""

        results.append({
            "region_name": region.region_name if region else "",
            "detailed_address": region.detailed_address if region else "",
            "created_at": log.created_at.isoformat() if log.created_at else None,
            "length": str(log.fish_length) if log.fish_length is not None else "0",
            "weight": str(log.fish_weight) if log.fish_weight is not None else "0",
            "price": str(log.market_price) if log.market_price is not None else "0",
            # ✅ 단일 이미지 URL 필드
            "image_url": image_url  
        })

    return jsonify(results)


# ✅ 영어 이름과 fish_id 매핑
fish_id_mapping = {
    "gamseongdom": 1,
    "jeomnongeo": 2,
    "neobchinongeo": 3,
    "nongeo": 4,
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








#---------------------------
#함수
#---------------------------



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
    region_name = data.get('location')
    
    if not user_id or not password or not username or not region_name:
        return jsonify({"error": "모든 필드를 입력해주세요."}), 400

    existing_user = Members.query.filter_by(user_id=user_id).first()
    if existing_user:
        return jsonify({"error": "이미 존재하는 아이디입니다."}), 400

    region = Region.query.filter_by(region_name=region_name).first()
    if not region:
        region = Region(region_name=region_name, detailed_address=region_name)
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
    app.run(debug=True, host='0.0.0.0', port=5000)
