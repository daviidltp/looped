# Spotify API

API para gestionar usuarios y su historial de reproducción de Spotify.

## Requisitos

- Docker
- Docker Compose
- Cuenta de desarrollador de Spotify

## Instalación y Uso

1. Clona el repositorio:
```bash
git clone <url-del-repositorio>
cd <nombre-del-directorio>
```

2. Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:
```env
SPOTIFY_CLIENT_ID=tu_client_id
SPOTIFY_CLIENT_SECRET=tu_client_secret
SPOTIFY_REDIRECT_URI=http://localhost:3000/callback
SECRET_KEY=tu_secret_key
```

3. Inicia los servicios:
```bash
docker-compose up --build
```

La API estará disponible en `http://localhost:5000`

## Endpoints

### Autenticación con Spotify

#### Login con Spotify
```http
POST /api/spotify-login
Content-Type: application/json

{
    "access_token": "spotify_access_token",
    "refresh_token": "spotify_refresh_token",
    "expires_in": 3600
}
```

#### Verificar Token
```http
GET /api/verify
Authorization: Bearer <jwt_token>
```

#### Refrescar Token de Spotify
```http
POST /api/refresh-spotify-token
Authorization: Bearer <jwt_token>
```

### Historial de Reproducción

#### Agregar Reproducción
```http
POST /api/play-history
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "track_id": "spotify_track_id",
    "track_name": "nombre_de_la_cancion",
    "artist_name": "nombre_del_artista",
    "played_at": "2024-01-01T12:00:00Z"
}
```

#### Obtener Historial
```http
GET /api/play-history?page=1&per_page=20&start_date=2024-01-01&end_date=2024-01-31
Authorization: Bearer <jwt_token>
```

#### Obtener Canciones Más Reproducidas
```http
GET /api/play-history/top-tracks?limit=10
Authorization: Bearer <jwt_token>
```

## Variables de Entorno

- `SPOTIFY_CLIENT_ID`: ID de cliente de tu aplicación de Spotify
- `SPOTIFY_CLIENT_SECRET`: Secreto de cliente de tu aplicación de Spotify
- `SPOTIFY_REDIRECT_URI`: URI de redirección configurada en tu aplicación de Spotify
- `SECRET_KEY`: Clave secreta para la generación de JWT
- `DATABASE_URL`: URL de conexión a la base de datos PostgreSQL
- `FLASK_DEBUG`: Modo debug de Flask (true/false)

## Desarrollo Local

1. Crea un entorno virtual:
```bash
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

2. Instala las dependencias:
```bash
pip install -r requirements.txt
```

3. Configura las variables de entorno en un archivo `.env`

4. Inicializa la base de datos:
```bash
python init_db.py
```

5. Ejecuta la aplicación:
```bash
python app.py
```

## Notas

- Asegúrate de tener una aplicación registrada en el [Dashboard de Desarrolladores de Spotify](https://developer.spotify.com/dashboard)
- La URI de redirección debe coincidir con la configurada en tu aplicación de Spotify
- Los tokens de Spotify expiran después de una hora, usa el endpoint de refresh para obtener nuevos tokens 