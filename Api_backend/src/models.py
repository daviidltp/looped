from .extensions import db
from datetime import datetime
import uuid

class User(db.Model):
    __tablename__ = 'usuarios'
    
    id = db.Column(db.String(50), primary_key=True, default=lambda: str(uuid.uuid4()))
    spotify_id = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    display_name = db.Column(db.String(120))
    country = db.Column(db.String(2))
    profile_image_url = db.Column(db.String(255))
    access_token = db.Column(db.String(255))
    refresh_token = db.Column(db.String(255))
    token_expires_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'spotify_id': self.spotify_id,
            'email': self.email,
            'display_name': self.display_name,
            'country': self.country,
            'profile_image_url': self.profile_image_url,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

class PlayHistory(db.Model):
    __tablename__ = 'historial_reproducciones'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.String(50), db.ForeignKey('usuarios.id'), nullable=False)
    track_id = db.Column(db.String(50), nullable=False)
    track_name = db.Column(db.String(255), nullable=False)
    artist_name = db.Column(db.String(255), nullable=False)
    album_name = db.Column(db.String(255))
    album_image_url = db.Column(db.String(255))
    played_at = db.Column(db.DateTime, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Restricción única para evitar duplicados
    __table_args__ = (
        db.UniqueConstraint('user_id', 'track_id', 'played_at', name='unique_play'),
    )

class UserStats(db.Model):
    __tablename__ = 'estadisticas_usuario'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.String(50), db.ForeignKey('usuarios.id'), nullable=False)
    track_id = db.Column(db.String(50), nullable=False)
    track_name = db.Column(db.String(255), nullable=False)
    artist_name = db.Column(db.String(255), nullable=False)
    album_name = db.Column(db.String(255))
    album_image_url = db.Column(db.String(255))
    play_count = db.Column(db.Integer, nullable=False)
    period_start = db.Column(db.DateTime, nullable=False)
    period_end = db.Column(db.DateTime, nullable=False)
    period_type = db.Column(db.String(20), nullable=False)  # 'hourly', 'daily', 'weekly'
    ranking = db.Column(db.Integer)  # posición en el ranking (1, 2, 3...)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Restricción única para evitar duplicados por período
    __table_args__ = (
        db.UniqueConstraint('user_id', 'track_id', 'period_start', 'period_type', name='unique_user_track_period'),
    )
