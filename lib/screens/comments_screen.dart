import 'package:flutter/material.dart';
import '../components/comments/comment_item.dart';
import '../components/comments/song_comment_section.dart';
import '../components/comments/comment_input.dart';
import '../services/auth_service.dart';
import '../utils/data_helpers.dart';

class CommentsScreen extends StatefulWidget {
  final String username;
  final List<Map<String, String>> songs;
  final List<Map<String, dynamic>> comments;

  const CommentsScreen({
    super.key,
    required this.username,
    required this.songs,
    required this.comments,
  });

  static Route<void> route({
    required String username,
    required List<Map<String, String>> songs,
    required List<Map<String, dynamic>> comments,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => CommentsScreen(
        username: username,
        songs: songs,
        comments: comments,
      ),
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

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  String? _currentUserProfilePic;
  String? _currentUsername;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profilePic = await AuthService.getProfilePic();
    final username = await AuthService.getUsername();
    if (mounted) {
      setState(() {
        _currentUserProfilePic = profilePic;
        _currentUsername = username;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSendComment() {
    // TODO: Implementar envío de comentario
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String postAuthorProfilePic = getProfilePicForUser(widget.username);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(postAuthorProfilePic),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Songs section
                  ...widget.songs.map((song) => SongCommentSection(
                    image: song['image']!,
                    title: song['title']!,
                    artist: song['artist']!,
                  )),
                  const SizedBox(height: 12),
                  const Text(
                    'Comentarios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comments section
                  if (widget.comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No hay comentarios aún',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...widget.comments.map((commentData) {
                      final commenterUsername = commentData['username'] as String;
                      final commenterProfilePic = getProfilePicForUser(commenterUsername);
                      return CommentItem(
                        username: commenterUsername,
                        profilePic: commenterProfilePic,
                        text: commentData['text'] as String,
                        time: commentData['time'] as String?,
                      );
                    }),
                ],
              ),
            ),
            // Comment input
            CommentInput(
              profilePic: _currentUserProfilePic,
              controller: _commentController,
              onSend: _handleSendComment,
            ),
          ],
        ),
      ),
    );
  }
}
