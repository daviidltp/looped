from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from apscheduler.schedulers.background import BackgroundScheduler

# Inicializar extensiones
db = SQLAlchemy()
cors = CORS(resources={
    r"/api/*": {
        "origins": ["http://localhost:3000", "http://localhost:5173"],  # Añade aquí la URL de tu frontend
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
jwt = JWTManager()
scheduler = BackgroundScheduler() 