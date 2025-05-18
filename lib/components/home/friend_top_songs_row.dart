import 'package:flutter/material.dart';
import 'friend_artwork_element.dart';
import 'friend_description.dart';
import '../detail/friend_songs_detail_page.dart';

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
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          _createRoute(
            context,
            FriendSongsDetailPage(
              songs: songs,
              profilePicUrl: profilePicUrl,
              name: name,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
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
      ),
    );
  }
  
  // Create slide-up route animation similar to comments screen
  Route _createRoute(BuildContext context, Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
        final offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      fullscreenDialog: true,
    );
  }
}
