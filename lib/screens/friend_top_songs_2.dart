import 'package:flutter/material.dart';
import 'friend_artwork_element.dart';
import 'friend_description.dart';
import 'dart:math';
import 'dart:ui';
import 'package:palette_generator/palette_generator.dart';

class FriendCarousel extends StatelessWidget {
  final List<Map<String, String>> songs; // Cada canción debe tener 'image', 'title', 'artist', 'plays'
  final String? description; // Descripción general sobre los bucles
  final String profilePicUrl;
  final String name;
  
  FriendCarousel({
    super.key, 
    required this.songs,
    this.description,
    required this.profilePicUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null && description!.isNotEmpty)
            FriendDescription(description: description!),
          ...songs.map((song) => Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: InkWell(
              onTap: () {
                // TODO: Handle tap on song
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(0),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: Hero(
                        tag: 'song_hero_${name}_${song['id'] ?? song['title']}',
                        child: Material(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          child: Image.network(
                            song['image'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song['artist']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${song['plays'] ?? '0'} reproducciones',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
