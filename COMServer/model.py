from app import db

class OnlieDevice(db.Model):
    __tablename__ = 'online_device'
    id = db.Column(db.Integer,primary_key=True)
    sid = db.Column(db.String)
    device = db.Column(db.String)