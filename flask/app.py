from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
CORS(app)  # 다른 도메인에서 오는 요청 허용

# MariaDB 연결 설정 (본인 DB 정보에 맞게 수정)
# 형식: mysql+pymysql://사용자:비밀번호@호스트/데이터베이스
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:0525@127.0.0.1/fishgo'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# ----------------------------
# 1) region 테이블 모델
# ----------------------------
class Region(db.Model):
    __tablename__ = 'region'  # 기존에 생성한 테이블명과 동일해야 함

    region_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    region_name = db.Column(db.String(100), nullable=False)
    detailed_address = db.Column(db.String(255))

    # 역방향 관계 예시 (Member, FishRegion에서 참조 가능)
    # members = db.relationship('Member', backref='region', lazy=True)
    # fish_region_assocs = db.relationship('FishRegion', backref='region', lazy=True)

    def to_json(self):
        return {
            "region_id": self.region_id,
            "region_name": self.region_name,
            "detailed_address": self.detailed_address
        }

# ----------------------------
# 2) member 테이블 모델
# ----------------------------
class Member(db.Model):
    __tablename__ = 'member'  # 기존에 생성한 테이블명과 동일해야 함

    uid = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    username = db.Column(db.String(100), nullable=False)
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='SET NULL'))
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())

    # region = db.relationship('Region', backref='members', lazy=True)

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
# 3) fish 테이블 모델
# ----------------------------
class Fish(db.Model):
    __tablename__ = 'fish'  # 기존에 생성한 테이블명과 동일해야 함

    fish_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    fish_name = db.Column(db.String(100), nullable=False)
    scientific_name = db.Column(db.String(255))
    morphological_info = db.Column(db.Text)
    taxonomy = db.Column(db.String(100))

    # fish_region_assocs = db.relationship('FishRegion', backref='fish', lazy=True)

    def to_json(self):
        return {
            "fish_id": self.fish_id,
            "fish_name": self.fish_name,
            "scientific_name": self.scientific_name,
            "morphological_info": self.morphological_info,
            "taxonomy": self.taxonomy
        }

# ----------------------------
# 4) fish_region 테이블 모델
# ----------------------------
class FishRegion(db.Model):
    __tablename__ = 'fish_region'  # 기존에 생성한 테이블명과 동일해야 함

    fish_id = db.Column(db.Integer, db.ForeignKey('fish.fish_id', ondelete='CASCADE'), primary_key=True)
    region_id = db.Column(db.Integer, db.ForeignKey('region.region_id', ondelete='CASCADE'), primary_key=True)

    # fish = db.relationship('Fish', backref='fish_region_assocs', lazy=True)
    # region = db.relationship('Region', backref='fish_region_assocs', lazy=True)

    def to_json(self):
        return {
            "fish_id": self.fish_id,
            "region_id": self.region_id
        }


# ------------------------------------------------
# Flask 실행
# ------------------------------------------------
if __name__ == '__main__':
    # 이미 테이블이 DB에 존재하면 create_all()은 무시되거나 오류 발생할 수 있음
    # (ORM 매핑 확인용으로만 사용)
    with app.app_context():
        db.create_all()

    app.run(debug=True, host='0.0.0.0', port=5000)
