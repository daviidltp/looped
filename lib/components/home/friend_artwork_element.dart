import 'package:flutter/material.dart';
import 'dart:math';

class FriendArtworkElement extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String artist;

  const FriendArtworkElement({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.artist,
  });

  @override
  State<FriendArtworkElement> createState() => _FriendArtworkElementState();
}

class _FriendArtworkElementState extends State<FriendArtworkElement> {
  late final int playCount;

  @override
  void initState() {
    super.initState();
    playCount = Random().nextInt(101); // Genera un número entre 0 y 100
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 35, 35, 35),
              ),
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: ${widget.imageUrl} - $error');
                        return Container(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note,
                                color: Colors.white54,
                                size: 40,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Album art",
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    )
                  : const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 40,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.loop,
              size: 14,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              playCount.toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 0),
        Text(
          widget.artist,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}