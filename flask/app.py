from flask import Flask, jsonify, request, session, send_from_directory, render_template
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.dialects.mysql import DECIMAL, ENUM
from sqlalchemy import func
from flask import send_from_directory
import os
import base64

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


#이미지 불러오는 API 엔드포인트
@app.route('/images/<filename>')
def get_image(filename):
    return send_from_directory('static/images', filename)

@app.route('/api/caught_fish', methods=['GET'])
def get_caught_fish():
    # 세션에서 uid 가져오기 (simulate_login 에서 uid=1이 저장됨)
    uid = session.get('uid')
    fish_id = request.args.get('fish_id', type=int)
    if uid is None or fish_id is None:
        return jsonify({"error": "uid와 fish_id 파라미터가 필요합니다."}), 400

    caught_fish_list = CaughtFish.query.filter_by(uid=uid, fish_id=fish_id).all()
    return jsonify([cf.to_json() for cf in caught_fish_list])



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
        region = Region.query.get(fr.region_id)
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


@app.route('/api/fishing_logs', methods=['GET'])
def get_fishing_logs():
    uid = request.args.get('uid', type=int)
    fish_id = request.args.get('fish_id', type=int)
    if uid is None or fish_id is None:
        return jsonify({"error": "uid와 fish_id 파라미터가 필요합니다."}), 400

    logs = FishingLog.query.filter_by(uid=uid, fish_id=fish_id).all()
    results = []
    for log in logs:
        # Region 테이블에서 해당 region_id로 지역 정보를 조회
        region = Region.query.get(log.region_id)
        results.append({
            "region_name": region.region_name if region else "",
            "detailed_address": region.detailed_address if region else "",
            "created_at": log.created_at.isoformat() if log.created_at else None,
            "length": str(log.fish_length) if log.fish_length is not None else "0",
            "weight": str(log.fish_weight) if log.fish_weight is not None else "0",
            "price": str(log.market_price) if log.market_price is not None else "0",
            # FishingLog 객체에 image_url 컬럼이 없다면, 이 부분은 조인이 필요합니다.
            "image_url": log.image_url if hasattr(log, 'image_url') else ""
        })
    return jsonify(results)


# ----------------------------
# 애플리케이션 시작
# ----------------------------
if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # 테이블 생성 (이미 존재하면 영향 없음)
    app.run(debug=True, host='0.0.0.0', port=5000)
