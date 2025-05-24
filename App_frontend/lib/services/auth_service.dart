import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es web

class AuthService {
  // Claves para SharedPreferences
  static const String spotifyTokenKey = 'spotify_token'; // Token de Spotify
  static const String backendTokenKey = 'backend_jwt_token'; // JWT de tu API Flask
  static const String emailKey = 'spotify_email';
  static const String topTracksKey = 'spotify_top_tracks';
  static const String recentlyPlayedKey = 'spotify_recently_played';
  static const String profilePicKey = 'spotify_profile_pic';
  static const String usernameKey = 'spotify_username';
  static const String userIdKey = 'backend_user_id'; // ID de usuario de tu BD

  // Configuración de la API Backend
  // AJUSTA ESTA URL SEGÚN TU ENTORNO:
  // - Emulador Android: 'http://10.0.2.2:5000'
  // - iOS / Dispositivo físico en misma red: 'http://<IP_DE_TU_PC>:5000'
  // - Flutter Web (servido localmente): 'http://localhost:5000'
  static String get backendBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    // Asume Android por defecto, puedes añadir más lógica para detectar iOS aquí
    // o pasar la IP como una variable de entorno a Flutter.
    return 'http://192.168.1.245:5000';
  }

  // Spotify API credentials
  static const String clientId = 'a6ce884a6ca2488b85baa8109ee8aa5b';
  static const String clientSecret = '4b78eb001625498d9612aef5eab8441a';
  // ¡IMPORTANTE! El redirectUri para mobile/desktop y web puede ser diferente.
  // 'http://127.0.0.1:8080' podría ser para una app web sirviéndose en ese puerto.
  // Para mobile, a menudo se usan custom schemes (ej: 'com.tuapp://callback')
  // o universal links. Asegúrate de que coincida con lo configurado en Spotify Developer Dashboard.
  static const String redirectUri = 'http://127.0.0.1:8080';
  static const String scope = 'user-top-read user-read-email user-read-recently-played';
  
  // --- Token de Spotify ---
  static Future<void> saveSpotifyToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(spotifyTokenKey, token);
    print('Token de Spotify guardado: $token');
  }
  
  static Future<String?> getSpotifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(spotifyTokenKey);
  }

  // --- JWT Token del Backend ---
  static Future<void> saveBackendToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(backendTokenKey, token);
    print('Token del Backend guardado: $token');
  }

  static Future<String?> getBackendToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(backendTokenKey);
  }

  // --- ID de Usuario del Backend ---
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
    print('ID de usuario del Backend guardado: $userId');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }
  
  // Store the user email
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(emailKey, email);
  }
  
  // Get the user email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailKey);
  }

  // Store profile picture URL
  static Future<void> saveProfilePic(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(profilePicKey, url);
  }

  // Get profile picture URL
  static Future<String?> getProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(profilePicKey);
  }

  // Store username
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, username);
  }

  // Get username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }
  
  // Store top tracks
  static Future<void> saveTopTracks(List<Map<String, dynamic>> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTracks = jsonEncode(tracks);
    await prefs.setString(topTracksKey, encodedTracks);
  }
  
  // Get top tracks
  static Future<List<Map<String, dynamic>>> getTopTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTracks = prefs.getString(topTracksKey);
    if (encodedTracks == null) {
      return [];
    }
    final List decodedList = jsonDecode(encodedTracks);
    return decodedList.cast<Map<String, dynamic>>();
  }
  
  // Store recently played tracks
  static Future<void> saveRecentlyPlayed(List<Map<String, dynamic>> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTracks = jsonEncode(tracks);
    await prefs.setString(recentlyPlayedKey, encodedTracks);
  }
  
  // Get recently played tracks
  static Future<List<Map<String, dynamic>>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTracks = prefs.getString(recentlyPlayedKey);
    if (encodedTracks == null) {
      return [];
    }
    final List decodedList = jsonDecode(encodedTracks);
    return decodedList.cast<Map<String, dynamic>>();
  }
  
  // Clear auth data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(spotifyTokenKey);
    await prefs.remove(backendTokenKey); // Limpiar token del backend también
    await prefs.remove(userIdKey); // Limpiar ID de usuario del backend
    await prefs.remove(emailKey);
    await prefs.remove(topTracksKey);
    await prefs.remove(recentlyPlayedKey);
    await prefs.remove(profilePicKey);
    await prefs.remove(usernameKey);
    print('Datos de sesión eliminados.');
  }
  
  // Check if user is authenticated (con el backend)
  static Future<bool> isAuthenticated() async {
    final token = await getBackendToken(); // Verificar el token de nuestro backend
    return token != null && token.isNotEmpty;
  }
  
  // Exchange code for token (Spotify) and then login to our backend
  static Future<Map<String, dynamic>?> exchangeCodeForToken(String code) async {
    String? spotifyAccessToken;
    String? spotifyRefreshToken; // Para almacenar el refresh token de Spotify
    int? spotifyExpiresIn;      // Para almacenar expires_in de Spotify

    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final spotifyApiData = jsonDecode(response.body);
        spotifyAccessToken = spotifyApiData['access_token'];
        spotifyRefreshToken = spotifyApiData['refresh_token']; // Capturar refresh_token
        spotifyExpiresIn = spotifyApiData['expires_in'];     // Capturar expires_in
        
        if (spotifyAccessToken == null) {
          print('Error: El token de acceso de Spotify es nulo.');
          return null;
        }
        await saveSpotifyToken(spotifyAccessToken!); // Guardar token de Spotify
        print('Token de Spotify obtenido: $spotifyAccessToken');

        // Ahora, "iniciar sesión" en nuestro backend Flask
        final backendLoginResponse = await http.post(
          Uri.parse('$backendBaseUrl/api/spotify-login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'access_token': spotifyAccessToken,
            'refresh_token': spotifyRefreshToken, // Enviar también el refresh_token de Spotify
            'expires_in': spotifyExpiresIn,       // Enviar también expires_in
          }),
        );

        if (backendLoginResponse.statusCode == 200) {
          final backendData = jsonDecode(backendLoginResponse.body);
          final String backendJwtToken = backendData['access_token'];
          final String backendUserId = backendData['user']?['id']; 
          // final String backendUserEmail = backendData['user']?['email']; // Opcional si lo necesitas directamente

          await saveBackendToken(backendJwtToken); // Guardar JWT de nuestro backend
          if (backendUserId != null) {
            await saveUserId(backendUserId);
          }
          print('Login exitoso con el backend. JWT guardado: $backendJwtToken');

          // Opcional: obtener perfil de Spotify y otros datos después del login al backend
          // ya que el token de Spotify ya fue validado por el backend.
          // Considera si estas llamadas deben hacerse aquí o en otra parte de la app.
          await fetchUserProfile(spotifyAccessToken!); 
          final topTracks = await fetchTopTracks(spotifyAccessToken!);
          final recentlyPlayed = await fetchRecentlyPlayed(spotifyAccessToken!);
          
          return {
            'backend_jwt': backendJwtToken, // Devolver el JWT del backend
            'spotify_token': spotifyAccessToken, // Todavía puede ser útil para llamadas directas a Spotify
            'user_id_backend': backendUserId,
            'topTracks': topTracks,
            'recentlyPlayed': recentlyPlayed,
          };

        } else {
          print('Error en login con el backend: ${backendLoginResponse.statusCode}');
          print('Respuesta del backend: ${backendLoginResponse.body}');
          return null;
        }
      } else {
        print('Error obteniendo token de Spotify: ${response.statusCode}');
        print('Respuesta de Spotify: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción en exchangeCodeForToken: $e');
      return null;
    }
  }
  
  // Fetch user profile (usa el token de Spotify)
  static Future<Map<String, dynamic>?> fetchUserProfile(String spotifyToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {
          'Authorization': 'Bearer $spotifyToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String email = data['email'] ?? 'N/A';
        final String username = data['display_name'] ?? 'Usuario';
        final String profilePic = data['images'] != null && (data['images'] as List).isNotEmpty 
            ? data['images'][0]['url'] 
            : 'https://randomuser.me/api/portraits/men/32.jpg'; // Placeholder
        
        await saveEmail(email);
        await saveUsername(username);
        await saveProfilePic(profilePic);
        
        return {
          'email': email,
          'username': username,
          'profilePic': profilePic,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
  
  // Fetch top tracks (usa el token de Spotify)
  static Future<List<Map<String, dynamic>>> fetchTopTracks(String spotifyToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/tracks?time_range=long_term&limit=3'),
        headers: {
          'Authorization': 'Bearer $spotifyToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Map<String, dynamic>> topTracks = 
            List<Map<String, dynamic>>.from(data['items']);
        
        await saveTopTracks(topTracks);
        return topTracks;
      }
      return [];
    } catch (e) {
      print('Error fetching top tracks: $e');
      return [];
    }
  }
  
  // Fetch recently played tracks (usa el token de Spotify)
  static Future<List<Map<String, dynamic>>> fetchRecentlyPlayed(String spotifyToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/recently-played?limit=50'),
        headers: {
          'Authorization': 'Bearer $spotifyToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Recently played data: $data'); // Print all values from the API
        
        final List<Map<String, dynamic>> recentlyPlayed = 
            List<Map<String, dynamic>>.from(data['items']);
        
        await saveRecentlyPlayed(recentlyPlayed);
        return recentlyPlayed;
      }
      return [];
    } catch (e) {
      print('Error fetching recently played tracks: $e');
      return [];
    }
  }
  
  // Get track info by ID
  static Future<Map<String, dynamic>?> getTrackById(String spotifyToken, String trackId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
        headers: {
          'Authorization': 'Bearer $spotifyToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching track: $e');
      return null;
    }
  }
  
  // Search tracks
  static Future<List<Map<String, dynamic>>> searchTracks(String spotifyToken, String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track&limit=1'),
        headers: {
          'Authorization': 'Bearer $spotifyToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tracks'] != null && data['tracks']['items'] != null) {
          return List<Map<String, dynamic>>.from(data['tracks']['items']);
        }
      }
      return [];
    } catch (e) {
      print('Error searching tracks: $e');
      return [];
    }
  }
} 