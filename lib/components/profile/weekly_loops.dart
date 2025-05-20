import 'package:flutter/material.dart';
import 'song_component.dart';

class WeeklyLoops extends StatelessWidget {
  final List<Map<String, String>> songs;

  const WeeklyLoops({
    super.key,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text(
          'Bucles de la semana',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: songs.isNotEmpty
              ? songs.map((song) => SongComponent(
                    imageUrl: song['image']!,
                    title: song['title']!,
                    artist: song['artist']!,
                    plays: song['plays']!,
                    duration: song['duration'],
                  )).toList()
              : [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'No hay canciones disponibles',
                        style: TextStyle(color: Colors.grey),
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