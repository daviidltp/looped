import 'package:flutter/material.dart';
import 'song_component.dart';

class WeeklyLoops extends StatelessWidget {
  final List<Map<String, String>> songs;
  final Map<String, dynamic> user;

  const WeeklyLoops({
    super.key,
    required this.songs,
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
                  Icons.loop,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bucles de la semana',
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
          Column(
            children: songs.isNotEmpty
                ? songs.map((song) => SongComponent(
                      imageUrl: song['image']!,
                      title: song['title']!,
                      artist: song['artist']!,
                      plays: song['plays']!,
                      duration: song['duration'],
                      user: user,
                    )).toList()
                : [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Center(
                        child: Text(
                          'No hay canciones disponibles',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
} 