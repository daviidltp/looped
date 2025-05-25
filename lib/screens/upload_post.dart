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
  bool _showSuccess = false;
  bool _slideDown = false;

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

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _uploading = false;
      _hideInputs = true;
    });

    await Future.delayed(const Duration(milliseconds: 400)); // Duración del fade out

    setState(() {
      _uploadSuccess = true;
      _slideDown = true;
    });

    await Future.delayed(const Duration(milliseconds: 500)); // Duración del deslizamiento

    setState(() {
      _showSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // Show a loading indicator or placeholder while user data is loading
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
            // Indicador de carga
            if (_uploading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  color: Colors.green,
                  minHeight: 4,
                ),
              ),

            // Texto principal
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: AnimatedSlide(
                offset: Offset(0, _slideDown ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text.rich(
                    key: ValueKey(_uploadSuccess),
                    TextSpan(
                      children: _uploadSuccess
                          ? [
                              TextSpan(
                                text: "Has subido tus bucles de la semana",
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ]
                          : [
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
            ),

            // Lottie de éxito (aparece después del deslizamiento)
            Positioned(
              top: 16, // Misma posición inicial que el texto
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showSuccess ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Lottie.asset(
                      'assets/success2.json',
                      repeat: false,
                    ),
                  ),
                ),
              ),
            ),

            // UserHeader
            Positioned(
              top: 80, // Ajustado según la altura aproximada del texto
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _hideInputs ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: UserHeader(
                  username: _user!['username'],
                  name: _user!['name'],
                  verificado: _user!['verificado'],
                  profilePic: _user!['profilePic'],
                ),
              ),
            ),

            // Campo de texto
            Positioned(
              top: 160, // Ajustado según la altura del UserHeader
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _hideInputs ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: TextField(
                  controller: _commentController,
                  maxLines: 2,
                  enabled: !_uploadSuccess,
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
            ),

            // FriendTopSongsRow
            Positioned(
              top: 240, // Ajustado según las posiciones anteriores
              left: 16,
              right: 16,
              child: AnimatedSlide(
                offset: Offset(0, _slideDown ? 0.0 : 0.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: FriendTopSongsRow(
                  songs: _topSongs,
                  name: _user!['name'],
                ),
              ),
            ),

            // Botón de subir
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _hideInputs ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 400),
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
                    child: Text(
                      _uploading ? 'Subiendo publicación' : 'Subir publicación',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}