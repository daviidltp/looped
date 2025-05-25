import 'package:flutter/material.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';

class FriendTopSongs extends StatelessWidget {
  final Map<String, String> song;
  final String name;
  final int plays;

  FriendTopSongs({
    super.key,
    required this.song,
    required this.name,
  }) : plays = Random().nextInt(101); // Random number between 0 and 100

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(0),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Material(
              color: const Color.fromARGB(255, 0, 0, 0),
              child: Image.network(
                song['image'] ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song['title'] ?? '',
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
                    song['artist'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      
                      SizedBox(
                        height: 28,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$plays reproducciones',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (plays > 50) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child:  SizedBox(
                          width: 32,
                          height: 32,
                          child: Lottie.asset(
                            'assets/fire_anim.json',
                            repeat: true,
                          ),
                        ),
                        ),
                       
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FriendTopSongsRow extends StatelessWidget {
  final List<Map<String, String>> songs; // Cada canción debe tener 'image', 'title', 'artist', 'plays'
  final String name;

  const FriendTopSongsRow({
    super.key,
    required this.songs,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => FriendTopSongs(
          song: songs[index],
          name: name,
        ),
      ),
    );
  }
}
