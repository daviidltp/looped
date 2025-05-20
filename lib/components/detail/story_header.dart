import 'package:flutter/material.dart';
import '../../utils/navigation_utils.dart';

class StoryHeader extends StatelessWidget {
  final Map<String, dynamic> user;

  const StoryHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtils.openProfileScreen(context, user);
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(user['profilePic'] ?? ''),
          ),
          const SizedBox(width: 8),
          Text(
            user['username'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 