from flask import Flask, jsonify  # jsonify: 데이터를 JSON 형태로 반환하기 위한 함수
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.dialects.mysql import DECIMAL, ENUM
from sqlalchemy import func  # 이 줄을 파일 상단에 추가



# Flask 애플리케이션 초기화 및 설정
app = Flask(__name__)
CORS(app)  # 다른 도메인에서 오는 요청을 허용

# MariaDB 연결 설정 (형식: mysql+pymysql://사용자:비밀번호@호스트/데이터베이스)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:0525@127.0.0.1/fishgo'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# SQLAlchemy 데이터베이스 객체 생성
db = SQLAlchemy(app)

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
    is_registered = db.Column(db.Boolean, default=False)  # 기본값 FALSE (미등록 상태)

    def to_json(self):
        return {
            "fish_id": self.fish_id,
            "fish_name": self.fish_name,
            "scientific_name": self.scientific_name,
            "morphological_info": self.morphological_info,
            "taxonomy": self.taxonomy,
            "is_registered": self.is_registered
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
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())

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
# 4) fish_region 테이블 모델
# ----------------------------
class FishRegion(db.Model):
    __tablename__ = 'fish_region'
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), primary_key=True)
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='CASCADE'), primary_key=True)

    def to_json(self):
        return {
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
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())
    post_status = db.Column(ENUM('판매중', '예약중', '거래완료'), default='판매중')

    def to_json(self):
        return {
            "post_id": self.post_id,
            "uid": self.uid,
            "title": self.title,
            "content": self.content,
            "like_count": self.like_count,
            "comment_count": self.comment_count,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "post_status": self.post_status
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
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())
    fish_length = db.Column(DECIMAL(10,2))
    fish_weight = db.Column(DECIMAL(10,2))
    market_price = db.Column(DECIMAL(10,2))
    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), nullable=False)

    def to_json(self):
        return {
            "log_id": self.log_id,
            "region_id": self.region_id,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "fish_length": float(self.fish_length) if self.fish_length is not None else None,
            "fish_weight": float(self.fish_weight) if self.fish_weight is not None else None,
            "market_price": float(self.market_price) if self.market_price is not None else None,
            "fish_id": self.fish_id
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
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())

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
# 추가된 API 엔드포인트: fish 테이블의 데이터를 JSON 형식으로 반환
# ----------------------------
# 파일 상단에 이미 import된 부분: from sqlalchemy import func

@app.route('/api/fishes', methods=['GET'])
def get_fishes():
    """
    각 물고기(fish) 별로 fishing_log 테이블에서 해당 fish_id와 일치하는 로그의 market_price 값을 모두 합산하여
    fish 객체에 price 필드로 추가한 후 JSON 형식으로 반환하는 API 엔드포인트.
    """
    fishes = Fish.query.all()
    results = []
    for fish in fishes:
        # 해당 물고기의 모든 fishing_log 레코드에서 market_price 값을 합산
        total_price = db.session.query(func.sum(FishingLog.market_price)) \
                        .filter(FishingLog.fish_id == fish.fish_id) \
                        .scalar() or 0
        fish_json = fish.to_json()
        # 합산된 가격을 정수로 변환하여 price 필드에 추가
        fish_json["price"] = int(total_price)
        results.append(fish_json)
    return jsonify(results)

# 애플리케이션 시작 전에 테이블을 생성 (이미 존재하면 영향을 주지 않음)
if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # 데이터베이스에 모든 테이블 생성
    # Flask 애플리케이션을 디버그 모드로 실행 (서버 주소: 0.0.0.0, 포트: 5000)
    app.run(debug=True, host='0.0.0.0', port=5000)
