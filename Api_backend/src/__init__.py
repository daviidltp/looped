from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from apscheduler.schedulers.background import BackgroundScheduler
import os
from dotenv import load_dotenv

# Importar configuraciones desde el directorio padre
import config # MODIFICADO

# Importar extensiones y modelos desde el paquete src
from .extensions import db, jwt, cors, scheduler # MODIFICADO
from .models import User # MODIFICADO (y otros modelos si son usados directamente aquí)
from .routes.api import api_bp # MODIFICADO
from .routes.auth import auth_bp  # AÑADIDO
from .services.scheduler import init_scheduler # MODIFICADO

load_dotenv()


def create_app(config_class=config.Config):
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_object(config_class)
    
    # Asegúrate de que la carpeta 'instance' exista
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # Inicializar extensiones
    db.init_app(app)
    jwt.init_app(app)
    cors.init_app(app, resources={r"/api/*": {"origins": os.getenv("CORS_ORIGINS", "*").split(",")}})
    
    # Crear tablas si no existen
    with app.app_context():
        db.create_all()
        print("Base de datos inicializada correctamente")

    # Registrar Blueprints
    app.register_blueprint(api_bp, url_prefix='/api')
    app.register_blueprint(auth_bp, url_prefix='/api')  # AÑADIDO

    # Inicializar y arrancar el scheduler
    if not scheduler.running:
        init_scheduler(app)
        if not app.config.get('TESTING', False) and not os.environ.get('WERKZEUG_RUN_MAIN'):
            try:
                scheduler.start()
                print("Scheduler iniciado.")
            except (KeyboardInterrupt, SystemExit):
                scheduler.shutdown()
                print("Scheduler detenido.")
            except Exception as e:
                print(f"Error al iniciar el scheduler: {e}")
        elif app.config.get('TESTING', False):
            print("Scheduler no iniciado en modo TESTING.")
        elif os.environ.get('WERKZEUG_RUN_MAIN'):
             print("Scheduler se iniciará en el proceso principal de Werkzeug.")


    @app.route('/')
    def health_check_root():
        return "API Backend is running!"

    return app
