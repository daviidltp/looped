import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrackService {
  static const String popularTracksKey = 'spotify_popular_tracks';
  
  // Clear cached popular tracks
  static Future<void> clearCachedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(popularTracksKey);
  }

  // Get all popular tracks with dynamic Spotify data
  static Future<List<List<Map<String, String>>>> getPopularTracksList() async {
    // Try to get cached data first
    final cachedData = await _getCachedPopularTracks();
    if (cachedData.isNotEmpty) {
      return cachedData;
    }

    final token = await AuthService.getToken();
    if (token == null) {
      return _getFallbackTracks();
    }

    try {
      // Define track IDs or search queries
      final trackInfoList = [
        // List 1
        [
          {'query': 'Vampire Olivia Rodrigo', 'id': '1kuGVB7EU95pJObxwvfwKS'},
          {'query': 'DROGA, Mora, C.Tangana', 'id': '18D0Za12EKUYklBQaJlaDP'},
          {'query': 'Polaris Quevedo', 'id': '31vU4u7g43Ve1MJ4UqYvqi'},
        ],
        // List 2
        [
          {'query': 'Rich Flex Drake 21 Savage', 'id': '1bDbXMyjaUCooNSCtbwMLU'},
          {'query': 'La Pantera La Pantera', 'id': '6i37QpS1w09aEzDb9dO0wW'},
          {'query': 'GRECAS GRECAS', 'id': '6i37QpS1w09aEzDb9dO0wW'},
        ],
        // List 3
        [
          {'query': 'Walls Walls', 'id': '6i37QpS1w09aEzDb9dO0wW'},
          {'query': 'Rauw Alejandro Rauw Alejandro', 'id': '6i37QpS1w09aEzDb9dO0wW'},
          {'query': 'Cruel Summer Taylor Swift', 'id': '1BxfuPKGuaTgP7aM0Bbdwr'},
        ],
        // List 4
        [
          {'query': 'Vampire Olivia Rodrigo', 'id': '1kuGVB7EU95pJObxwvfwKS'},
          {'query': 'Anti-Hero Taylor Swift', 'id': '0V3wPSX9ygBnCm8psDIegu'},
          {'query': 'Polaris Quevedo', 'id': '31vU4u7g43Ve1MJ4UqYvqi'},
        ],
        // List 5
        [
          {'query': 'Rich Flex Drake 21 Savage', 'id': '1bDbXMyjaUCooNSCtbwMLU'},
          {'query': 'La Pantera La Pantera', 'id': '6i37QpS1w09aEzDb9dO0wW'},
          {'query': 'GRECAS GRECAS', 'id': '6i37QpS1w09aEzDb9dO0wW'},
        ],
      ];

      List<List<Map<String, String>>> result = [];

      // Process each group of tracks
      for (var trackGroup in trackInfoList) {
        List<Map<String, String>> formattedGroup = [];
        
        for (var trackInfo in trackGroup) {
          var trackData = await _getTrackData(token, trackInfo['id']!, trackInfo['query']!);
          if (trackData != null) {
            formattedGroup.add(trackData);
          }
        }
        
        if (formattedGroup.isNotEmpty) {
          result.add(formattedGroup);
        }
      }

      if (result.isNotEmpty) {
        // Cache the result
        await _cachePopularTracks(result);
        return result;
      }
      
      return _getFallbackTracks();
    } catch (e) {
      print('Error loading tracks: $e');
      return _getFallbackTracks();
    }
  }

  // Cache popular tracks
  static Future<void> _cachePopularTracks(List<List<Map<String, String>>> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTracks = jsonEncode(tracks);
    await prefs.setString(popularTracksKey, encodedTracks);
  }

  // Get cached popular tracks
  static Future<List<List<Map<String, String>>>> _getCachedPopularTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTracks = prefs.getString(popularTracksKey);
    if (encodedTracks == null) {
      return [];
    }
    final List<dynamic> decodedList = jsonDecode(encodedTracks);
    return decodedList.map((group) {
      final List<dynamic> trackGroup = group as List<dynamic>;
      return trackGroup.map((track) {
        final Map<String, dynamic> trackMap = track as Map<String, dynamic>;
        return Map<String, String>.from(trackMap);
      }).toList();
    }).toList();
  }

  // Get track data from Spotify API
  static Future<Map<String, String>?> _getTrackData(String token, String trackId, String query) async {
    try {
      // Try to get by ID first
      var track = await AuthService.getTrackById(token, trackId);
      
      // If ID fails, try search
      if (track == null) {
        final searchResults = await AuthService.searchTracks(token, query);
        if (searchResults.isNotEmpty) {
          track = searchResults.first;
        }
      }
      
      if (track != null) {
        String? imageUrl;
        if (track['album'] != null && 
            track['album']['images'] != null && 
            (track['album']['images'] as List).isNotEmpty) {
          imageUrl = track['album']['images'][0]['url'];
        }
        
        String artistNames = '';
        if (track['artists'] != null && (track['artists'] as List).isNotEmpty) {
          artistNames = (track['artists'] as List)
              .map((artist) => artist['name'])
              .join(', ');
        }

        // Format duration from milliseconds to MM:SS
        String duration = '';
        if (track['duration_ms'] != null) {
          final int ms = track['duration_ms'] as int;
          final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
          final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
          duration = '$minutes:$seconds';
        }
        
        return {
          'title': track['name'] ?? 'Unknown Track',
          'artist': artistNames.isNotEmpty ? artistNames : 'Unknown Artist',
          'image': imageUrl ?? '',
          'id': track['id'] ?? '',
          'duration': duration,
        };
      }
    } catch (e) {
      print('Error fetching track $trackId: $e');
    }
    
    // Fallback to basic info if API fails
    return {
      'title': query.split(' ').take(2).join(' '),
      'artist': query.split(' ').skip(2).join(' '),
      'image': '',
      'id': '',
      'duration': '',
    };
  }

  // Fallback track data if API fails
  static List<List<Map<String, String>>> _getFallbackTracks() {
    return [
      [
        {
          'title': 'Flowers',
          'artist': 'Miley Cyrus',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
          'id': '',
          'duration': '03:20',
        },
        {
          'title': 'As It Was',
          'artist': 'Harry Styles',
          'image': 'https://i.scdn.co/image/ab67616d0000b2732e8ed79e177ff6011076f5f0',
          'id': '',
          'duration': '02:47',
        },
        {
          'title': 'Titi Me Preguntó',
          'artist': 'Bad Bunny',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
          'id': '',
          'duration': '04:03',
        },
      ],
      [
        {
          'title': 'Stay',
          'artist': 'The Kid LAROI, Justin Bieber',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
          'id': '',
          'duration': '02:21',
        },
        {
          'title': 'Industry Baby',
          'artist': 'Lil Nas X, Jack Harlow',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
          'id': '',
          'duration': '03:32',
        },
        {
          'title': 'abcdefu',
          'artist': 'GAYLE',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
          'id': '',
          'duration': '02:48',
        },
      ],
    ];
  }
} 