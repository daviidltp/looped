import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'spotify_token';
  static const String emailKey = 'spotify_email';
  static const String topTracksKey = 'spotify_top_tracks';
  static const String recentlyPlayedKey = 'spotify_recently_played';
  static const String profilePicKey = 'spotify_profile_pic';
  static const String usernameKey = 'spotify_username';
  
  // Spotify API credentials
  static const String clientId = 'a6ce884a6ca2488b85baa8109ee8aa5b';
  static const String clientSecret = '4b78eb001625498d9612aef5eab8441a';
  static const String redirectUri = 'http://127.0.0.1:8080';
  static const String scope = 'user-top-read user-read-email user-read-recently-played';
  
  // Store the access token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    print('Token saved: $token');
  }
  
  // Get the access token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
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
    await prefs.remove(tokenKey);
    await prefs.remove(emailKey);
    await prefs.remove(topTracksKey);
    await prefs.remove(recentlyPlayedKey);
    await prefs.remove(profilePicKey);
    await prefs.remove(usernameKey);
  }
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Exchange code for token
  static Future<Map<String, dynamic>?> exchangeCodeForToken(String code) async {
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
        final data = jsonDecode(response.body);
        final String accessToken = data['access_token'];
        
        // Save token
        await saveToken(accessToken);
        
        // Get user profile
        await fetchUserProfile(accessToken);
        
        // Get top tracks
        final topTracks = await fetchTopTracks(accessToken);
        
        // Get recently played tracks
        final recentlyPlayed = await fetchRecentlyPlayed(accessToken);
        
        return {
          'token': accessToken,
          'topTracks': topTracks,
          'recentlyPlayed': recentlyPlayed,
        };
      }
      return null;
    } catch (e) {
      print('Error exchanging code for token: $e');
      return null;
    }
  }
  
  // Fetch user profile
  static Future<Map<String, dynamic>?> fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String email = data['email'];
        final String username = data['display_name'];
        final String profilePic = data['images'] != null && (data['images'] as List).isNotEmpty 
            ? data['images'][0]['url'] 
            : 'https://randomuser.me/api/portraits/men/32.jpg';
        
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
  
  // Fetch top tracks
  static Future<List<Map<String, dynamic>>> fetchTopTracks(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/tracks?time_range=long_term&limit=3'),
        headers: {
          'Authorization': 'Bearer $token',
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
  
  // Fetch recently played tracks
  static Future<List<Map<String, dynamic>>> fetchRecentlyPlayed(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/recently-played?limit=50'),
        headers: {
          'Authorization': 'Bearer $token',
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
  static Future<Map<String, dynamic>?> getTrackById(String token, String trackId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
        headers: {
          'Authorization': 'Bearer $token',
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
  static Future<List<Map<String, dynamic>>> searchTracks(String token, String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track&limit=1'),
        headers: {
          'Authorization': 'Bearer $token',
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