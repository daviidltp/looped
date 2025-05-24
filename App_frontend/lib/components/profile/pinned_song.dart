import 'package:flutter/material.dart';
import 'song_component.dart';

class PinnedSong extends StatelessWidget {
  final Map<String, String> song;
  final Map<String, dynamic> user;

  const PinnedSong({
    super.key,
    required this.song,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.push_pin,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  'Canción fijada',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SongComponent(
            imageUrl: song['image']!,
            title: song['title']!,
            artist: song['artist']!,
            plays: song['plays']!,
            showPlays: false,
            duration: song['duration'],
            user: user,
          ),
        ],
      ),
    );
  }
} 