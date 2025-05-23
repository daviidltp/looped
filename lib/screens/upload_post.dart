import 'package:flutter/material.dart';
import '../components/user_header.dart';
import '../components/home/friend_top_songs_row.dart';
import '../components/comments/comment_input.dart';
import '../data/users_data.dart';
import '../services/auth_service.dart';
import '../services/track_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class UploadPostScreen extends StatefulWidget {
  const UploadPostScreen({super.key});

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  Map<String, dynamic>? _user;
  List<Map<String, String>> _topSongs = [];
  bool _loading = true;
  bool _uploading = false;
  bool _uploadSuccess = false;
  bool _hideInputs = false;

  late final AnimationController _successAnimController;
  late final Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _loadUserAndSongs();
    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successAnim = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _successAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndSongs() async {
    // Obtener username actual
    final username = await AuthService.getUsername() ?? 'david';
    // Buscar usuario en usersData
    final user = usersData.firstWhere(
      (u) => u['username'] == username,
      orElse: () => usersData.firstWhere((u) => u['username'] == 'david'),
    );
    // Obtener top tracks del usuario
    final topTracksRaw = await AuthService.getTopTracks();
    // Formatear para FriendTopSongsRow
    final topTracks = topTracksRaw.take(3).map<Map<String, String>>((track) {
      final imageUrl = track['album'] != null && (track['album']['images'] as List).isNotEmpty
          ? (track['album']['images'][0]['url']) as String
          : '';
      return {
        'title': track['name'] ?? '',
        'artist': track['artists'] != null && (track['artists'] as List).isNotEmpty
            ? ((track['artists'] as List).map((a) => a['name']).join(', '))
            : '',
        'image': imageUrl,
      };
    }).toList();

    setState(() {
      _user = user;
      _topSongs = topTracks.length == 3
          ? topTracks
          : [
              ...topTracks,
              ...List.generate(3 - topTracks.length, (_) => {
                    'title': '',
                    'artist': '',
                    'image': '',
                  })
            ];
      _loading = false;
    });
  }

  void _handleUpload() async {
    setState(() {
      _uploading = true;
    });
    await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      _uploading = false;
      _uploadSuccess = true;
      _hideInputs = true;
    });
    _successAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String firstName = (_user!['name'] as String).split(' ').first;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // LinearProgressIndicator arriba del todo
            if (_uploading)
              const LinearProgressIndicator(
                backgroundColor: Colors.white12,
                color: Colors.green,
                minHeight: 4,
              ),
            // Contenido principal
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Espacio para el Lottie y texto de éxito
                        if (_uploadSuccess) ...[
                          const SizedBox(height: 32),
                          Center(
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: Lottie.asset(
                                'assets/success2.json',
                                repeat: false,
                              ),
                            ),
                          ),
                          FadeTransition(
                            opacity: _successAnim,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                              child: Text(
                                "Has subido tus bucles de la semana",
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Texto animado pre-éxito
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 2.0, left: 16, right: 16),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
                              child: Text.rich(
                                key: const ValueKey('preSuccess'),
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: firstName,
                                      style: GoogleFonts.raleway(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ", estos han sido tus bucles de la semana",
                                      style: GoogleFonts.raleway(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        // Fade out de UserHeader y descripción
                        AnimatedOpacity(
                          opacity: _hideInputs ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 400),
                          child: Column(
                            children: [
                              if (!_uploadSuccess)
                                UserHeader(
                                  username: _user!['username'],
                                  name: _user!['name'],
                                  verificado: _user!['verificado'],
                                  profilePic: _user!['profilePic'],
                                ),
                              if (!_uploadSuccess)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                  child: TextField(
                                    controller: _commentController,
                                    maxLines: 2,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Describe tu publicación...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // FriendTopSongsRow animado hacia abajo (menos distancia)
                        AnimatedSlide(
                          offset: _uploadSuccess ? const Offset(0, 0.12) : Offset.zero,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: FriendTopSongsRow(
                              songs: _topSongs,
                              name: _user!['name'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón solo si no se ha subido
                AnimatedOpacity(
                  opacity: _hideInputs ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: (!_uploadSuccess)
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: (_uploading || _uploadSuccess) ? null : _handleUpload,
                              child: _uploading
                                  ? const Text(
                                      'Subiendo publicación',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    )
                                  : const Text(
                                      'Subir publicación',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
