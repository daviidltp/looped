import spotipy
from spotipy.oauth2 import SpotifyOAuth
from datetime import datetime, timedelta
from sqlalchemy import func, desc
from ..models import User, PlayHistory, UserStats
from ..extensions import db
import logging
import os # Necesario para las variables de entorno de Spotify

logger = logging.getLogger(__name__)

class SpotifySync:
    
    @staticmethod
    def _refresh_spotify_token(user):
        """Intenta refrescar el token de Spotify para un usuario."""
        if not user.refresh_token:
            logger.warning(f"Usuario {user.id} no tiene refresh_token. No se puede refrescar.")
            return False

        try:
            # SPOTIPY_CLIENT_ID y SPOTIPY_CLIENT_SECRET deben estar configuradas como variables de entorno
            # o cargadas en la configuración de Flask.
            # Spotipy buscará automáticamente SPOTIPY_CLIENT_ID, SPOTIPY_CLIENT_SECRET, SPOTIPY_REDIRECT_URI
            # en las variables de entorno si no se pasan explícitamente.
            # Asegúrate de que config.py las cargue o que estén en tu .env
            
            client_id = os.environ.get('SPOTIFY_CLIENT_ID')
            client_secret = os.environ.get('SPOTIFY_CLIENT_SECRET')
            redirect_uri = os.environ.get('SPOTIFY_REDIRECT_URI') # Aunque no se usa directamente aquí, es buena práctica tenerla.

            if not client_id or not client_secret:
                logger.error("SPOTIFY_CLIENT_ID o SPOTIFY_CLIENT_SECRET no están configuradas. No se puede refrescar token.")
                return False

            sp_oauth = SpotifyOAuth(
                client_id=client_id,
                client_secret=client_secret,
                redirect_uri=redirect_uri, # Este no es estrictamente necesario para el flujo de refresh_token, pero SpotifyOAuth lo puede requerir
                scope=None # No se necesita un scope específico para refrescar
            )
            
            token_info = sp_oauth.refresh_access_token(user.refresh_token)

            if token_info:
                user.access_token = token_info['access_token']
                user.token_expires_at = datetime.utcnow() + timedelta(seconds=token_info['expires_in'])
                # Spotify puede o no devolver un nuevo refresh_token. Si lo hace, actualízalo.
                if 'refresh_token' in token_info:
                    user.refresh_token = token_info['refresh_token']
                
                db.session.commit()
                logger.info(f"Token de Spotify refrescado exitosamente para el usuario {user.id}")
                return True
            else:
                logger.error(f"No se pudo refrescar el token de Spotify para el usuario {user.id}. Token_info vacío.")
                return False
        except Exception as e:
            logger.error(f"Excepción al intentar refrescar el token de Spotify para el usuario {user.id}: {str(e)}")
            # Podríamos querer invalidar el refresh_token aquí si el error indica que es inválido
            # user.refresh_token = None 
            # db.session.commit()
            return False

    @staticmethod
    def sync_user_recent_tracks(user_id):
        """Sincroniza las reproducciones recientes de un usuario desde Spotify"""
        try:
            user = User.query.get(user_id)
            if not user:
                logger.warning(f"Usuario {user_id} no encontrado.")
                return False

            if not user.access_token:
                logger.warning(f"Usuario {user.id} no tiene access_token. Sincronización omitida.")
                return False
            
            # Verificar si el token ha expirado e intentar refrescar si es necesario
            if user.token_expires_at and user.token_expires_at < datetime.utcnow():
                logger.info(f"Token de Spotify expirado para el usuario {user.id}. Intentando refrescar...")
                if not SpotifySync._refresh_spotify_token(user):
                    logger.error(f"No se pudo refrescar el token para el usuario {user.id}. Sincronización omitida.")
                    return False
            
            # Crear cliente de Spotify con el token (posiblemente recién refrescado)
            sp = spotipy.Spotify(auth=user.access_token)
            
            # Obtener última reproducción guardada
            last_play = PlayHistory.query.filter_by(user_id=user_id)\
                .order_by(PlayHistory.played_at.desc()).first()
            
            # Si hay reproducciones previas, buscar desde la última
            # El API de Spotify espera el timestamp en milisegundos
            after_timestamp_ms = int(last_play.played_at.timestamp() * 1000) if last_play else None
            
            # Obtener reproducciones recientes desde Spotify
            # El endpoint 'current_user_recently_played' devuelve las últimas 50 por defecto.
            # El parámetro 'after' es un timestamp Unix en milisegundos. Solo devolverá items DESPUÉS de este timestamp.
            recent_tracks_data = sp.current_user_recently_played(limit=50, after=after_timestamp_ms)
            
            added_count = 0
            if recent_tracks_data and 'items' in recent_tracks_data:
                for item in recent_tracks_data['items']:
                    track_info = item['track']
                    # Spotify devuelve played_at en formato ISO 8601 con 'Z' (UTC)
                    played_at_dt = datetime.strptime(item['played_at'], '%Y-%m-%dT%H:%M:%S.%fZ')
                    
                    # Verificar si esta reproducción ya existe para evitar IntegrityError y optimizar
                    exists = db.session.query(PlayHistory.id).filter_by(
                        user_id=user_id, 
                        track_id=track_info['id'], 
                        played_at=played_at_dt
                    ).first()
                    if exists:
                        continue

                    play_history_entry = PlayHistory(
                        user_id=user_id,
                        track_id=track_info['id'],
                        track_name=track_info['name'],
                        artist_name=', '.join([artist['name'] for artist in track_info['artists']]),
                        album_name=track_info['album']['name'],
                        album_image_url=track_info['album']['images'][0]['url'] if track_info['album']['images'] else None,
                        played_at=played_at_dt
                    )
                    
                    db.session.add(play_history_entry)
                    added_count += 1
                
                if added_count > 0:
                    db.session.commit()
            
            logger.info(f"Sincronizadas {added_count} nuevas reproducciones para usuario {user_id}")
            return True
            
        except spotipy.SpotifyException as e:
            logger.error(f"Error de Spotify API sincronizando usuario {user_id}: {str(e)}. Status: {e.http_status}")
            if e.http_status == 401: # Token inválido o expirado y no se pudo refrescar
                logger.warning(f"El token para el usuario {user.id} es inválido (401). Necesita re-autenticación.")
                # Podríamos limpiar el token aquí para forzar una nueva autenticación la próxima vez
                # user.access_token = None
                # user.token_expires_at = None
                # db.session.commit()
            db.session.rollback()
            return False
        except Exception as e:
            logger.error(f"Excepción general sincronizando usuario {user_id}: {str(e)}")
            db.session.rollback()
            return False
    
    @staticmethod
    def generate_hourly_stats():
        """Genera estadísticas horarias para TODOS los usuarios registrados"""
        try:
            # Definir período (última hora)
            end_time = datetime.utcnow()
            start_time = end_time - timedelta(hours=1)
            
            all_users = User.query.all() # Obtener TODOS los usuarios
            
            users_synced_count = 0
            for user in all_users:
                user_id = user.id
                
                # Primero sincronizar datos recientes del usuario actual
                if SpotifySync.sync_user_recent_tracks(user_id):
                    # Generar estadísticas del período solo si la sincronización fue exitosa
                    # (o si queremos generar stats incluso con datos potencialmente desactualizados)
                    SpotifySync.generate_user_period_stats(user_id, start_time, end_time, 'hourly')
                    users_synced_count +=1
            
            logger.info(f"Proceso de estadísticas horarias completado. {users_synced_count}/{len(all_users)} usuarios procesados para estadísticas.")
            
        except Exception as e:
            logger.error(f"Error generando estadísticas horarias global: {str(e)}")
    
    @staticmethod
    def generate_user_period_stats(user_id, start_time, end_time, period_type='hourly'):
        """Genera estadísticas de un usuario para un período específico"""
        try:
            # Obtener top tracks del período
            top_tracks = db.session.query(
                PlayHistory.track_id,
                PlayHistory.track_name,
                PlayHistory.artist_name,
                PlayHistory.album_name,
                PlayHistory.album_image_url,
                func.count(PlayHistory.id).label('play_count')
            ).filter(
                PlayHistory.user_id == user_id,
                PlayHistory.played_at >= start_time,
                PlayHistory.played_at < end_time # Exclusivo en el final del período
            ).group_by(
                PlayHistory.track_id,
                PlayHistory.track_name,
                PlayHistory.artist_name,
                PlayHistory.album_name,
                PlayHistory.album_image_url
            ).order_by(
                desc('play_count')
            ).limit(10).all()  # Top 10 para este período
            
            stats_added_count = 0
            for rank, track_stat_info in enumerate(top_tracks, 1):
                # Evitar duplicados en UserStats
                exists = db.session.query(UserStats.id).filter_by(
                    user_id=user_id,
                    track_id=track_stat_info.track_id,
                    period_start=start_time,
                    period_type=period_type
                ).first()
                if exists:
                    continue

                user_stat_entry = UserStats(
                    user_id=user_id,
                    track_id=track_stat_info.track_id,
                    track_name=track_stat_info.track_name,
                    artist_name=track_stat_info.artist_name,
                    album_name=track_stat_info.album_name,
                    album_image_url=track_stat_info.album_image_url,
                    play_count=track_stat_info.play_count,
                    period_start=start_time,
                    period_end=end_time,
                    period_type=period_type,
                    ranking=rank
                )
                
                db.session.add(user_stat_entry)
                stats_added_count +=1
            
            if stats_added_count > 0:
                db.session.commit()
            
            logger.info(f"Generadas {stats_added_count} entradas de estadísticas ({period_type}) para usuario {user_id}")
            
        except Exception as e:
            logger.error(f"Error generando estadísticas ({period_type}) para usuario {user_id}: {str(e)}")
            db.session.rollback()
    
    @staticmethod
    def get_user_weekly_top_3(user_id):
        """Obtiene las 3 canciones más escuchadas de la semana"""
        try:
            # Calcular rango de la semana actual (Lunes 00:00:00 a Domingo 23:59:59 UTC)
            now = datetime.utcnow()
            # Ir al inicio del día actual
            start_of_today = now.replace(hour=0, minute=0, second=0, microsecond=0)
            # Restar días para llegar al lunes (weekday() es 0 para lunes, 6 para domingo)
            week_start = start_of_today - timedelta(days=now.weekday())
            week_end = week_start + timedelta(days=7) # El final es el inicio del siguiente lunes
            
            # Obtener top 3 de la semana actual desde las estadísticas horarias acumuladas
            top_3_tracks = db.session.query(
                UserStats.track_id,
                UserStats.track_name,
                UserStats.artist_name,
                UserStats.album_name,
                UserStats.album_image_url,
                func.sum(UserStats.play_count).label('total_plays')
            ).filter(
                UserStats.user_id == user_id,
                UserStats.period_start >= week_start,
                UserStats.period_start < week_end, # Usar period_start para el filtrado semanal
                UserStats.period_type == 'hourly' # Agrupar basándose en las estadísticas horarias
            ).group_by(
                UserStats.track_id,
                UserStats.track_name,
                UserStats.artist_name,
                UserStats.album_name,
                UserStats.album_image_url
            ).order_by(
                desc('total_plays')
            ).limit(3).all()
            
            return [{
                'track_id': track.track_id,
                'track_name': track.track_name,
                'artist_name': track.artist_name,
                'album_name': track.album_name,
                'album_image_url': track.album_image_url,
                'total_plays': track.total_plays,
                'week_start': week_start.isoformat(),
                'week_end': (week_end - timedelta(seconds=1)).isoformat() # Para mostrar el fin del domingo
            } for track in top_3_tracks]
            
        except Exception as e:
            logger.error(f"Error obteniendo top 3 semanal para usuario {user_id}: {str(e)}")
            return [] 