import 'package:flutter/material.dart';
import 'song_component.dart';

class PinnedSong extends StatelessWidget {
  final Map<String, String> song;

  const PinnedSong({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text(
          'Canción fijada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SongComponent(
          imageUrl: song['image']!,
          title: song['title']!,
          artist: song['artist']!,
          plays: song['plays']!,
          showPlays: false,
        ),
      ],
      ),
    );
  }
} 