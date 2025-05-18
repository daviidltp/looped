import 'package:flutter/material.dart';
import '../components/profile/profile_header.dart';
import '../components/profile/pinned_song.dart';
import '../components/profile/weekly_loops.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _topTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Load top tracks
    final topTracks = await AuthService.getTopTracks();
    
    setState(() {
      _topTracks = topTracks;
      _isLoading = false;
    });
  }

  // Convert Spotify track format to app format
  List<Map<String, String>> _formatTopTracks() {
    return _topTracks.map((track) {
      final String imageUrl = track['album'] != null && 
              (track['album']['images'] as List).isNotEmpty
          ? (track['album']['images'][0]['url']) as String
          : '';
      
      return {
        'title': (track['name'] ?? 'Unknown Track') as String,
        'artist': track['artists'] != null && (track['artists'] as List).isNotEmpty
            ? ((track['artists'] as List).map((artist) => artist['name']).join(', ')) as String
            : 'Unknown Artist',
        'image': imageUrl,
        'plays': (track['popularity'] ?? '0').toString(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Format tracks if available
    final List<Map<String, String>> formattedTracks = 
        _topTracks.isNotEmpty ? _formatTopTracks() : [];
    
    return _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ProfileHeader(),
                  const SizedBox(height: 32),
                  if (formattedTracks.isNotEmpty) ...[
                    PinnedSong(song: formattedTracks[0]),
                    const SizedBox(height: 32),
                  ],
                  WeeklyLoops(songs: formattedTracks),
                ],
              ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
} 