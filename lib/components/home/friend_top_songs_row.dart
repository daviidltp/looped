import 'package:flutter/material.dart';
import 'friend_artwork_element.dart';
import 'friend_description.dart';

class FriendTopSongsRow extends StatelessWidget {
  final List<Map<String, String>> songs; // Cada canción debe tener 'image', 'title', 'artist'
  final String? description; // Descripción general sobre los bucles
  final String profilePicUrl;
  final String name;
  
  const FriendTopSongsRow({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null && description!.isNotEmpty)
            FriendDescription(description: description!),
          Row(
            children: [
              Expanded(
                child: FriendArtworkElement(
                  imageUrl: songs[0]['image'] ?? '',
                  title: songs[0]['title']!,
                  artist: songs[0]['artist']!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FriendArtworkElement(
                  imageUrl: songs[1]['image'] ?? '',
                  title: songs[1]['title']!,
                  artist: songs[1]['artist']!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FriendArtworkElement(
                  imageUrl: songs[2]['image'] ?? '',
                  title: songs[2]['title']!,
                  artist: songs[2]['artist']!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
