import 'package:flutter/material.dart';
import '../home/friend_header.dart';

class FriendSongsDetailPage extends StatefulWidget {
  final List<Map<String, String>> songs;
  final String profilePicUrl;
  final String name;
  
  const FriendSongsDetailPage({
    Key? key,
    required this.songs,
    required this.profilePicUrl,
    required this.name,
  }) : super(key: key);

  @override
  State<FriendSongsDetailPage> createState() => _FriendSongsDetailPageState();
}

class _FriendSongsDetailPageState extends State<FriendSongsDetailPage> {
  int _currentIndex = 0;
  
  void _nextSong() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.songs.length;
    });
  }
  
  void _previousSong() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.songs.length) % widget.songs.length;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final currentSong = widget.songs[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: FriendHeader(
            profilePicUrl: widget.profilePicUrl,
            name: widget.name,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousSong();
          } else {
            _nextSong();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Artworks apilados en el centro
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Artwork 3 (al fondo)
                    if (widget.songs.length > 2)
                      Transform.translate(
                        offset: const Offset(40, -20),
                        child: Transform.scale(
                          scale: 0.85,
                          child: _buildArtwork(widget.songs[(_currentIndex + 2) % widget.songs.length]['image'] ?? ''),
                        ),
                      ),
                    // Artwork 2 (en medio)
                    if (widget.songs.length > 1)
                      Transform.translate(
                        offset: const Offset(20, -10),
                        child: Transform.scale(
                          scale: 0.9,
                          child: _buildArtwork(widget.songs[(_currentIndex + 1) % widget.songs.length]['image'] ?? ''),
                        ),
                      ),
                    // Artwork 1 (al frente)
                    _buildArtwork(currentSong['image'] ?? ''),
                  ],
                ),
                
                // Información de la canción pegada al artwork
                const SizedBox(height: 16),
                Text(
                  currentSong['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  currentSong['artist'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork(String imageUrl) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 35, 35, 35),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color.fromARGB(255, 35, 35, 35),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 80,
                    ),
                  );
                },
              )
            : const Icon(
                Icons.music_note,
                color: Colors.white54,
                size: 80,
              ),
      ),
    );
  }
} 