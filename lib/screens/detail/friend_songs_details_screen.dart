import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/auth_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'dart:async';
import '../../components/detail/story_header.dart';

class FriendSongsDetailPage extends StatefulWidget {
  final List<Map<String, String>> songs;
  final Map<String, dynamic> user;
  
  const FriendSongsDetailPage({
    super.key,
    required this.songs,
    required this.user,
  });

  @override
  State<FriendSongsDetailPage> createState() => _FriendSongsDetailPageState();
}

class _FriendSongsDetailPageState extends State<FriendSongsDetailPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _autoAdvanceTimer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  DateTime? _tapDownTime;
  bool _isPaused = false;
  static const int _storyDurationMs = 5000; // Duración de cada historia en milisegundos
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _storyDurationMs),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _startAutoAdvance();
    _updateSongData();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _progressController.reset();
    _progressController.forward();
    
    _autoAdvanceTimer = Timer(Duration(milliseconds: _storyDurationMs), () {
      if (!mounted) return;
      
      if (_currentIndex < widget.songs.length - 1) {
        setState(() {
          _currentIndex++;
          _updateSongData();
        });
        _startAutoAdvance();
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  void _nextSong() {
    if (_currentIndex < widget.songs.length - 1) {
      setState(() {
        _currentIndex++;
        _updateSongData();
      });
      _startAutoAdvance();
    }
  }

  void _previousSong() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _updateSongData();
      });
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _updateSongData() async {
    final currentSong = widget.songs[_currentIndex];
    final trackId = currentSong['id'];
    if (trackId != null) {
      final token = await AuthService.getToken();
      if (token != null) {
        final trackData = await AuthService.getTrackById(token, trackId);
        if (trackData != null) {
          setState(() {
            if (trackData['duration_ms'] != null) {
              _totalDuration = Duration(milliseconds: trackData['duration_ms']);
              _currentDuration = Duration.zero;
            }
          });
        }
      }
    }
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  Widget _buildDisc(String imageUrl, {double size = 300, double opacity = 1.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
            offset: Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
              )
            : Container(
                color: Colors.grey[900],
                child: Icon(Icons.music_note, size: size * 0.3, color: Colors.white54),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.songs[_currentIndex];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Capa base: Fondo y contenido visual
          Container(color: Colors.black),
          
          // Imagen con blur
          Positioned.fill(
            child: ClipRect(
              child: Image.network(
                currentSong['image'] ?? '',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),

          // Degradado
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(1),
                  ],
                  stops: const [0, 0.3, 0.6],
                ),
              ),
            ),
          ),

          // 2. Contenido principal (sin IgnorePointer)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 0), // Espacio para el header y barra de progreso
                Expanded( // Reemplazamos los Spacer() por un Expanded
                  child: Center( // Añadimos un Center para centrar verticalmente
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Centramos el contenido verticalmente
                      children: [
                        // Disco actual
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_currentIndex == 0)
                              Hero(
                                tag: 'song_hero_${widget.user['name']}_${widget.songs[0]['id'] ?? widget.songs[0]['title']}',
                                child: _buildDisc(currentSong['image'] ?? ''),
                              )
                            else
                              _buildDisc(currentSong['image'] ?? ''),
                          ],
                        ),
                        const SizedBox(height: 100), // Espacio entre el disco y el texto
                        // Info de la canción y botones
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Text(
                                currentSong['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                (currentSong['artist'] ?? '') + (currentSong['album'] != null ? ' · ${currentSong['album']}' : ''),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${_formatDuration(_currentDuration)} / ${_formatDuration(_totalDuration)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                  fontFamily: 'monospace',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),

          // 3. GestureDetector para navegación
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                _tapDownTime = DateTime.now();
                final screenWidth = MediaQuery.of(context).size.width;
                final tapX = details.globalPosition.dx;
                
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_tapDownTime != null && !_isPaused) {
                    _autoAdvanceTimer?.cancel();
                    _progressController.stop();
                    _isPaused = true;
                    _fadeController.reverse();
                  }
                });
              },
              onTapUp: (details) {
                final tapDuration = DateTime.now().difference(_tapDownTime ?? DateTime.now());
                final screenWidth = MediaQuery.of(context).size.width;
                final tapX = details.globalPosition.dx;

                if (tapDuration.inMilliseconds < 100) {
                  if (tapX < screenWidth / 2) {
                    _previousSong();
                  } else {
                    if (_currentIndex == widget.songs.length - 1) {
                      Navigator.of(context).pop();
                    } else {
                      _nextSong();
                    }
                  }
                } else if (_isPaused) {
                  final remainingDuration = Duration(
                    milliseconds: (_storyDurationMs * (1 - _progressAnimation.value)).round()
                  );
                  _autoAdvanceTimer = Timer(remainingDuration, () {
                    if (!mounted) return;
                    if (_currentIndex < widget.songs.length - 1) {
                      setState(() {
                        _currentIndex++;
                        _updateSongData();
                      });
                      _startAutoAdvance();
                    } else {
                      Navigator.of(context).pop();
                    }
                  });
                  _progressController.forward(from: _progressAnimation.value);
                  _isPaused = false;
                  _fadeController.forward();
                }
                _tapDownTime = null;
              },
              onTapCancel: () {
                if (_isPaused) {
                  final remainingDuration = Duration(
                    milliseconds: (_storyDurationMs * (1 - _progressAnimation.value)).round()
                  );
                  _autoAdvanceTimer = Timer(remainingDuration, () {
                    if (!mounted) return;
                    if (_currentIndex < widget.songs.length - 1) {
                      setState(() {
                        _currentIndex++;
                        _updateSongData();
                      });
                      _startAutoAdvance();
                    } else {
                      Navigator.of(context).pop();
                    }
                  });
                  _progressController.forward(from: _progressAnimation.value);
                  _isPaused = false;
                  _fadeController.forward();
                }
                _tapDownTime = null;
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // 4. Header y barra de progreso (última capa, por encima de todo)
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Barra de progreso
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      children: List.generate(
                        widget.songs.length,
                        (index) => Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: index == _currentIndex
                                ? AnimatedBuilder(
                                    animation: _progressAnimation,
                                    builder: (context, child) {
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _progressAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : index < _currentIndex
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // StoryHeader
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 6.0),
                    child: StoryHeader(
                      user: widget.user,
                    ),
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