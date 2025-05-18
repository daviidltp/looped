import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class TrackService {
  // Get all popular tracks with dynamic Spotify data
  static Future<List<List<Map<String, String>>>> getPopularTracksList() async {
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
          {'query': 'Anti-Hero Taylor Swift', 'id': '0V3wPSX9ygBnCm8psDIegu'},
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

      return result.isNotEmpty ? result : _getFallbackTracks();
    } catch (e) {
      print('Error loading tracks: $e');
      return _getFallbackTracks();
    }
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
        
        return {
          'title': track['name'] ?? 'Unknown Track',
          'artist': artistNames.isNotEmpty ? artistNames : 'Unknown Artist',
          'image': imageUrl ?? '',
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
        },
        {
          'title': 'As It Was',
          'artist': 'Harry Styles',
          'image': 'https://i.scdn.co/image/ab67616d0000b2732e8ed79e177ff6011076f5f0',
        },
        {
          'title': 'Titi Me Preguntó',
          'artist': 'Bad Bunny',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
        },
      ],
      [
        {
          'title': 'Stay',
          'artist': 'The Kid LAROI, Justin Bieber',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
        },
        {
          'title': 'Industry Baby',
          'artist': 'Lil Nas X, Jack Harlow',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
        },
        {
          'title': 'abcdefu',
          'artist': 'GAYLE',
          'image': 'https://i.scdn.co/image/ab67616d0000b273f429549123dbe8552764ba1d',
        },
      ],
    ];
  }
} 