from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from datetime import timedelta, datetime
from ..models import User
from ..extensions import db
import spotipy

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/spotify-login', methods=['POST'])
def spotify_login():
    """
    Endpoint para autenticar usuario con token de Spotify.
    Recibe el token de Spotify y crea/actualiza el usuario en la base de datos.
    """
    try:
        data = request.get_json()
        if not data or 'access_token' not in data:
            return jsonify({'error': 'Se requiere el token de acceso de Spotify'}), 400

        # Obtener información del usuario de Spotify
        sp = spotipy.Spotify(auth=data['access_token'])
        spotify_user = sp.current_user()
        
        # Buscar o crear usuario
        user = User.query.filter_by(spotify_id=spotify_user['id']).first()
        
        if not user:
            # Crear nuevo usuario
            user = User(
                spotify_id=spotify_user['id'],
                email=spotify_user['email'],
                display_name=spotify_user['display_name'],
                country=spotify_user.get('country'),
                profile_image_url=spotify_user['images'][0]['url'] if spotify_user['images'] else None,
                access_token=data['access_token'],
                refresh_token=data.get('refresh_token'),
                token_expires_at=datetime.utcnow() + timedelta(seconds=data.get('expires_in', 3600))
            )
            db.session.add(user)
        else:
            # Actualizar tokens del usuario existente
            user.access_token = data['access_token']
            user.refresh_token = data.get('refresh_token')
            user.token_expires_at = datetime.utcnow() + timedelta(seconds=data.get('expires_in', 3600))
        
        db.session.commit()
        
        # Crear JWT para nuestra aplicación
        access_token = create_access_token(identity=user.id)
        
        return jsonify({
            'access_token': access_token,
            'user': {
                'id': user.id,
                'spotify_id': user.spotify_id,
                'display_name': user.display_name,
                'email': user.email
            }
        }), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 400

@auth_bp.route('/verify', methods=['GET'])
@jwt_required()
def verify_token():
    """Verifica la validez del token JWT y el estado de la sesión de Spotify"""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if not user:
        return jsonify({'error': 'Usuario no encontrado'}), 404
    
    # Verificar si el token de Spotify ha expirado
    spotify_token_expired = user.token_expires_at < datetime.utcnow() if user.token_expires_at else True
        
    return jsonify({
        'valid': True,
        'spotify_token_expired': spotify_token_expired
    }), 200 