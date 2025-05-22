import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../screens/profile_screen.dart';
import '../screens/comments_screen.dart';
import '../screens/detail/friend_songs_details_screen.dart';

class NavigationUtils {
  static void openProfileScreen(BuildContext context, Map<String, dynamic> user) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ProfileScreen(
          user: user,
          isCurrentUser: false,
          onToggleFollow: () {
            // TODO: Implement follow/unfollow functionality
          },
        ),
      ),
    );
  }

  static void openCommentsScreen(
    BuildContext context, {
    required String username,
    required List<Map<String, String>> songs,
    required List<Map<String, dynamic>> comments,
  }) {
    Navigator.of(context).push(
      CommentsScreen.route(
        username: username,
        songs: songs,
        comments: comments,
      ),
    );
  }

  static void openSongsDetailScreen(
    BuildContext context, {
    required List<Map<String, String>> songs,
    required Map<String, dynamic> user,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FriendSongsDetailPage(
          songs: songs,
          user: user,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      ),
    );
  }
} 