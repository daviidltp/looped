import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/data_helpers.dart';

class FriendCommentsSection extends StatelessWidget {
  final List<Map<String, String>> comments;
  final String username;
  final List<Map<String, String>> songs;

  const FriendCommentsSection({
    super.key,
    required this.comments,
    required this.username,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comments.isEmpty)
            Row(
              children: [
                FutureBuilder<String?>(
                  future: AuthService.getProfilePic(),
                  builder: (context, snapshot) {
                    return CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(snapshot.data ?? 'https://randomuser.me/api/portraits/men/32.jpg'),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'Añade un comentario...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                // Mostrar solo el primer comentario en la preview
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        getProfilePicForUser(comments[0]['username'] as String),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '@${comments[0]['username']} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: comments[0]['text'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comments[0]['time']!,
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (comments.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ver ${comments.length - 1} comentario${comments.length - 1 != 1 ? 's' : ''} más',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 14,
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