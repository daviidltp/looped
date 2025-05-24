# Este archivo se encarga de inicializar la base de datos pero no se usa en la app es solo para pruebas por si se borra la base de datos

from . import create_app
from looped.Api_backend.src.extensions import db
from looped.Api_backend.src.models import User, PlayHistory
import os
from dotenv import load_dotenv
from sqlalchemy import text
from datetime import datetime, timedelta
from sqlalchemy.sql import func, desc

# Cargar variables de entorno
load_dotenv()

def init_database():
    app = create_app()
    
    with app.app_context():
        try:
            # Desactivar restricciones de clave foránea temporalmente
            db.session.execute(text("SET session_replication_role = 'replica';"))
            
            # Eliminar tablas si existen
            db.session.execute(text("DROP TABLE IF EXISTS historial_reproducciones CASCADE;"))
            db.session.execute(text("DROP TABLE IF EXISTS usuarios CASCADE;"))
            
            # Reactivar restricciones de clave foránea
            db.session.execute(text("SET session_replication_role = 'origin';"))
            
            # Hacer commit de los cambios
            db.session.commit()
            
            print("Tablas existentes eliminadas correctamente")
            
            # Crear nuevas tablas
            db.create_all()
            print("Nuevas tablas creadas correctamente")
            
            # Crear un usuario de prueba
            test_user = User(
                email="test@example.com",
                username="testuser"
            )
            test_user.set_password("testpass123")
            db.session.add(test_user)
            db.session.commit()
            
            print("Usuario de prueba creado correctamente")
            
            # Agregar algunas reproducciones de prueba
            now = datetime.utcnow()
            plays = [
                PlayHistory(
                    user_id=test_user.id,
                    track_id="123456",
                    track_name="Canción de Prueba 1",
                    artist_name="Artista 1",
                    album_name="Álbum 1",
                    album_image_url="https://ejemplo.com/imagen1.jpg",
                    played_at=now - timedelta(hours=1)
                ),
                PlayHistory(
                    user_id=test_user.id,
                    track_id="123456",
                    track_name="Canción de Prueba 1",
                    artist_name="Artista 1",
                    album_name="Álbum 1",
                    album_image_url="https://ejemplo.com/imagen1.jpg",
                    played_at=now - timedelta(hours=2)
                ),
                PlayHistory(
                    user_id=test_user.id,
                    track_id="789012",
                    track_name="Canción de Prueba 2",
                    artist_name="Artista 2",
                    album_name="Álbum 2",
                    album_image_url="https://ejemplo.com/imagen2.jpg",
                    played_at=now - timedelta(hours=3)
                )
            ]
            
            for play in plays:
                db.session.add(play)
            db.session.commit()
            
            print("Reproducciones de prueba agregadas correctamente")
            
            # Verificar las reproducciones agregadas
            plays = PlayHistory.query.all()
            print(f"\nReproducciones en la base de datos:")
            for play in plays:
                print(f"- {play.track_name} por {play.artist_name} reproducida en {play.played_at}")
            
            # Verificar la consulta de canciones más escuchadas
            top_tracks = db.session.query(
                PlayHistory.track_id,
                PlayHistory.track_name,
                PlayHistory.artist_name,
                PlayHistory.album_name,
                PlayHistory.album_image_url,
                func.count(PlayHistory.id).label('play_count')
            ).filter(
                PlayHistory.user_id == test_user.id,
                PlayHistory.played_at >= now - timedelta(days=7)
            ).group_by(
                PlayHistory.track_id,
                PlayHistory.track_name,
                PlayHistory.artist_name,
                PlayHistory.album_name,
                PlayHistory.album_image_url
            ).order_by(
                desc('play_count')
            ).limit(3).all()
            
            print(f"\nCanciones más escuchadas:")
            for track in top_tracks:
                print(f"- {track.track_name} por {track.artist_name} ({track.play_count} reproducciones)")
            
        except Exception as e:
            print(f"Error durante la inicialización: {e}")
            db.session.rollback()
            raise

if __name__ == "__main__":
    print("Iniciando inicialización de la base de datos...")
    init_database()
    print("Inicialización completada") 