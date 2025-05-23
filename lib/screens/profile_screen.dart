import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/profile/profile_header.dart';
import '../components/profile/pinned_song.dart';
import '../components/home/friend_carousel.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isCurrentUser;
  final VoidCallback? onToggleFollow;
  
  const ProfileScreen({
    super.key,
    required this.user,
    this.isCurrentUser = true,
    this.onToggleFollow,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _topTracks = [];
  bool _isLoading = true;
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user['isFriend'] ?? false;
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
      
      // Format duration from milliseconds to MM:SS
      String duration = '';
      if (track['duration_ms'] != null) {
        final int ms = track['duration_ms'] as int;
        final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
        final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
        duration = '$minutes:$seconds';
      }
      
      return {
        'title': (track['name'] ?? 'Unknown Track') as String,
        'artist': track['artists'] != null && (track['artists'] as List).isNotEmpty
            ? ((track['artists'] as List).map((artist) => artist['name']).join(', '))
            : 'Unknown Artist',
        'image': imageUrl,
        'plays': (track['popularity'] ?? '0').toString(),
        'duration': duration,
      };
    }).toList();
  }

  void _handleToggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    if (widget.onToggleFollow != null) {
      widget.onToggleFollow!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tracks if available
    final List<Map<String, String>> formattedTracks = 
        _topTracks.isNotEmpty ? _formatTopTracks() : [];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          '@${widget.user['username']}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : FocusScope(
              canRequestFocus: false,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileHeader(
                        isCurrentUser: widget.isCurrentUser,
                        user: widget.user,
                        isFriend: _isFollowing,
                        onToggleFollow: _handleToggleFollow,
                        labels: widget.user['labels'] ?? ['Lo-Fi', 'Pop', 'Regueton',],
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.push_pin,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Canción fijada',
                              style: GoogleFonts.raleway(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      if (formattedTracks.isNotEmpty) ...[
                        PinnedSong(
                          song: formattedTracks[0],
                          user: widget.user,
                        ),
                        const SizedBox(height: 32),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.loop, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "Últimos bucles de la semana",
                              style: GoogleFonts.raleway(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      FriendCarousel(
                        songs: formattedTracks,
                        profilePicUrl: widget.user['profilePicUrl'] ?? '',
                        name: widget.user['username'] ?? '',
                        description: null,
                      ),
                    ],
                  ),
                ),
              ),
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