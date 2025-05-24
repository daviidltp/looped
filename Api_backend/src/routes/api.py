from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..extensions import db
from ..models import User, PlayHistory, UserStats
from ..services.spotify_sync import SpotifySync
from datetime import datetime, timedelta
from sqlalchemy import func, desc
from sqlalchemy.exc import IntegrityError

api_bp = Blueprint('api', __name__)

@api_bp.route('/delete-users', methods=['DELETE'])
@jwt_required()
def delete_user():
    """
    Elimina un usuario y todo su historial.
    Requiere autenticación JWT.
    """
    user_id = get_jwt_identity()
    
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({"error": "User not found"}), 404
        
        db.session.delete(user)
        db.session.commit()
        
        return jsonify({
            "message": "User and all associated data deleted successfully"
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# ===== HISTORIAL DE REPRODUCCIONES =====

@api_bp.route('/update-history', methods=['POST'])
@jwt_required()
def add_play_history():
    """
    Añade nuevas reproducciones al historial.
    Requiere autenticación JWT.
    
    Payload:
    [
        {
            user_id=user_id,
			track_id=play['track_id'],
			track_name=play['track_name'],
			artist_name=play['artist_name'],
			album_name=play.get('album_name'),
			album_image_url=play.get('album_image_url'),
			played_at=played_at
        }
    ]
    """
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    if not isinstance(data, list):
        return jsonify({"error": "Data must be a list of plays"}), 400
    
    results = {
        "added": 0,
        "skipped": 0,
        "errors": 0,
        "plays": []
    }
    
    for play in data:
        try:
            # Validar campos requeridos
            required_fields = ['track_id', 'track_name', 'artist_name', 'played_at']
            for field in required_fields:
                if field not in play:
                    results["errors"] += 1
                    continue
            
            # Convertir played_at a datetime
            try:
                played_at = datetime.fromisoformat(play['played_at'])
            except ValueError:
                results["errors"] += 1
                continue
            
            # Intentar crear el registro
            play_history = PlayHistory(
                user_id=user_id,
                track_id=play['track_id'],
                track_name=play['track_name'],
                artist_name=play['artist_name'],
                album_name=play.get('album_name'),
                album_image_url=play.get('album_image_url'),
                played_at=played_at
            )
            
            db.session.add(play_history)
            db.session.commit()
            
            results["added"] += 1
            results["plays"].append({
                "id": play_history.id,
                "track_id": play_history.track_id,
                "track_name": play_history.track_name,
                "played_at": play_history.played_at.isoformat()
            })
            
        except IntegrityError:
            # Si hay duplicado, ignorar y continuar
            db.session.rollback()
            results["skipped"] += 1
            continue
        except Exception as e:
            db.session.rollback()
            results["errors"] += 1
            continue
    
    return jsonify({
        "message": "Play history processed",
        "results": results
    }), 200

@api_bp.route('/play-history', methods=['GET'])
@jwt_required()
def get_play_history():
    """
    Obtiene el historial de reproducciones.
    Requiere autenticación JWT.
    
    Query Parameters:
    - page: Número de página (default: 1)
    - per_page: Elementos por página (default: 20)
    - start_date: Fecha inicial (ISO8601)
    - end_date: Fecha final (ISO8601)
    """
    user_id = get_jwt_identity()
    
    # Parámetros de paginación
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    # Parámetros de filtrado
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    
    query = PlayHistory.query.filter_by(user_id=user_id)
    
    # Aplicar filtros de fecha si se proporcionan
    if start_date:
        try:
            start_date = datetime.fromisoformat(start_date)
            query = query.filter(PlayHistory.played_at >= start_date)
        except ValueError:
            return jsonify({"error": "Invalid start_date format"}), 400
            
    if end_date:
        try:
            end_date = datetime.fromisoformat(end_date)
            query = query.filter(PlayHistory.played_at <= end_date)
        except ValueError:
            return jsonify({"error": "Invalid end_date format"}), 400
    
    # Ordenar por fecha de reproducción (más reciente primero)
    query = query.order_by(PlayHistory.played_at.desc())
    
    # Paginar resultados
    pagination = query.paginate(page=page, per_page=per_page)
    
    return jsonify({
        "total": pagination.total,
        "pages": pagination.pages,
        "current_page": page,
        "per_page": per_page,
        "plays": [{
            "id": play.id,
            "track_id": play.track_id,
            "track_name": play.track_name,
            "artist_name": play.artist_name,
            "album_name": play.album_name,
            "album_image_url": play.album_image_url,
            "played_at": play.played_at.isoformat(),
            "created_at": play.created_at.isoformat()
        } for play in pagination.items]
    })

@api_bp.route('/play-history/top-tracks', methods=['GET'])
@jwt_required()
def get_top_tracks():
    """
    Obtiene las canciones más escuchadas.
    Requiere autenticación JWT.
    
    Query Parameters:
    - limit: Número de canciones a retornar (default: 3)
    - period: Período de tiempo (default: 'week', opciones: 'day', 'week', 'month', 'year')
    """
    user_id = get_jwt_identity()
    limit = request.args.get('limit', 3, type=int)
    period = request.args.get('period', 'week')
    
    # Calcular fecha de inicio según el período
    now = datetime.utcnow()
    if period == 'day':
        start_date = now - timedelta(days=1)
    elif period == 'week':
        start_date = now - timedelta(weeks=1)
    elif period == 'month':
        start_date = now - timedelta(days=30)
    elif period == 'year':
        start_date = now - timedelta(days=365)
    else:
        return jsonify({"error": "Invalid period"}), 400
    
    # Consulta para obtener las canciones más escuchadas
    top_tracks = db.session.query(
        PlayHistory.track_id,
        PlayHistory.track_name,
        PlayHistory.artist_name,
        PlayHistory.album_name,
        PlayHistory.album_image_url,
        func.count(PlayHistory.id).label('play_count')
    ).filter(
        PlayHistory.user_id == user_id,
        PlayHistory.played_at >= start_date
    ).group_by(
        PlayHistory.track_id,
        PlayHistory.track_name,
        PlayHistory.artist_name,
        PlayHistory.album_name,
        PlayHistory.album_image_url
    ).order_by(
        desc('play_count')
    ).limit(limit).all()
    
    return jsonify({
        "period": period,
        "start_date": start_date.isoformat(),
        "tracks": [{
            "track_id": track.track_id,
            "track_name": track.track_name,
            "artist_name": track.artist_name,
            "album_name": track.album_name,
            "album_image_url": track.album_image_url,
            "play_count": track.play_count
        } for track in top_tracks]
    })

# ===== SINCRONIZACIÓN AUTOMÁTICA =====

@api_bp.route('/sync/manual', methods=['POST'])
@jwt_required()
def manual_sync():
    """Sincroniza manualmente las reproducciones del usuario desde Spotify"""
    user_id = get_jwt_identity()
    
    try:
        success = SpotifySync.sync_user_recent_tracks(user_id)
        
        if success:
            return jsonify({
                "message": "Sincronización completada exitosamente"
            }), 200
        else:
            return jsonify({
                "error": "Error en la sincronización - verifique su token de Spotify"
            }), 400
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@api_bp.route('/stats/weekly-top-3', methods=['GET'])
@jwt_required()
def get_weekly_top_3():
    """Obtiene las 3 canciones más escuchadas de la semana actual"""
    user_id = get_jwt_identity()
    
    try:
        top_3 = SpotifySync.get_user_weekly_top_3(user_id)
        
        return jsonify({
            "weekly_top_3": top_3
        }), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@api_bp.route('/stats/history', methods=['GET'])
@jwt_required()
def get_stats_history():
    """
    Obtiene el historial de estadísticas del usuario.
    
    Query Parameters:
    - period_type: Tipo de período ('hourly', 'daily', 'weekly')
    - start_date: Fecha inicial (ISO8601)
    - end_date: Fecha final (ISO8601)
    - limit: Número de registros (default: 100)
    """
    user_id = get_jwt_identity()
    
    period_type = request.args.get('period_type', 'hourly')
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    limit = request.args.get('limit', 100, type=int)
    
    try:
        query = UserStats.query.filter_by(user_id=user_id, period_type=period_type)
        
        if start_date:
            start_date = datetime.fromisoformat(start_date)
            query = query.filter(UserStats.period_start >= start_date)
            
        if end_date:
            end_date = datetime.fromisoformat(end_date)
            query = query.filter(UserStats.period_end <= end_date)
        
        stats = query.order_by(UserStats.period_start.desc()).limit(limit).all()
        
        return jsonify({
            "stats": [{
                "track_id": stat.track_id,
                "track_name": stat.track_name,
                "artist_name": stat.artist_name,
                "album_name": stat.album_name,
                "album_image_url": stat.album_image_url,
                "play_count": stat.play_count,
                "ranking": stat.ranking,
                "period_start": stat.period_start.isoformat(),
                "period_end": stat.period_end.isoformat(),
                "period_type": stat.period_type
            } for stat in stats]
        }), 200
        
    except ValueError:
        return jsonify({"error": "Formato de fecha inválido"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500 