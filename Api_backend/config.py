import os
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Database
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'connect_args': {
            'connect_timeout': 10,
            'application_name': 'spotify_app'
            # 'sslmode': 'require' # Comentado para Docker local, necesario para Supabase
        }
    }
    
    # App
    # SECRET_KEY es usado por Flask para sesiones, cookies firmadas, y por Flask-JWT-Extended si JWT_SECRET_KEY no se define explícitamente.
    SECRET_KEY = os.environ.get('SECRET_KEY', 'defecto-muy-inseguro-cambiar-esto') 
    DEBUG = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    
    # CORS
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', '*').split(',')
    
    # Configuración de JWT
    # Es buena práctica usar una clave diferente para JWT si es posible, pero SECRET_KEY puede usarse.
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', SECRET_KEY) # Usa JWT_SECRET_KEY de .env, o fallback a SECRET_KEY
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=int(os.environ.get('JWT_ACCESS_TOKEN_EXPIRES_HOURS', '1')))
    
    # Configuración de Spotify
    SPOTIFY_CLIENT_ID = os.environ.get('SPOTIFY_CLIENT_ID')
    SPOTIFY_CLIENT_SECRET = os.environ.get('SPOTIFY_CLIENT_SECRET')
    SPOTIFY_REDIRECT_URI = os.environ.get('SPOTIFY_REDIRECT_URI', 'http://localhost:3000/callback')
    
    @staticmethod
    def init_app(app):
        """Inicializa la aplicación con configuraciones específicas"""
        pass
