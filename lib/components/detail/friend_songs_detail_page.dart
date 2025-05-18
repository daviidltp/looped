import 'package:flutter/material.dart';
import '../home/friend_header.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';

// Función top-level para el isolate
@pragma('vm:entry-point')
Future<void> computePalette(List<Object> args) async {
  try {
    var imageBytes = args[0] as Uint8List;
    var port = args[1] as SendPort;
    
    final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(imageBytes),
      maximumColorCount: 8,
    );
    
    // Junta todos los colores posibles, sin duplicados ni nulos
    final Set<Color> colorSet = {};
    
    // Añadir colores de la paleta general primero
    if (palette.colors.isNotEmpty) {
      colorSet.addAll(palette.colors);
    }
    
    // Añadir colores específicos si están disponibles
    if (palette.dominantColor?.color != null) colorSet.add(palette.dominantColor!.color);
    if (palette.vibrantColor?.color != null) colorSet.add(palette.vibrantColor!.color);
    if (palette.lightVibrantColor?.color != null) colorSet.add(palette.lightVibrantColor!.color);
    if (palette.darkVibrantColor?.color != null) colorSet.add(palette.darkVibrantColor!.color);
    if (palette.mutedColor?.color != null) colorSet.add(palette.mutedColor!.color);
    if (palette.lightMutedColor?.color != null) colorSet.add(palette.lightMutedColor!.color);
    if (palette.darkMutedColor?.color != null) colorSet.add(palette.darkMutedColor!.color);

    // Convertir los colores a una lista y enviarla
    List<int> colors = colorSet.map((color) => color.value).toList();
    print('Extracted colors: ${colors.length}'); // Debug print
    port.send(colors);
  } catch (e) {
    print('Error in isolate: $e');
    (args[1] as SendPort).send([]);
  }
}

class FriendSongsDetailPage extends StatefulWidget {
  final List<Map<String, String>> songs;
  final String profilePicUrl;
  final String name;
  
  const FriendSongsDetailPage({
    super.key,
    required this.songs,
    required this.profilePicUrl,
    required this.name,
  });

  @override
  State<FriendSongsDetailPage> createState() => _FriendSongsDetailPageState();
}

class _FriendSongsDetailPageState extends State<FriendSongsDetailPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Color> _paletteColors = [
    const Color(0xFFF06292), // Pinkish-red
    const Color(0xFFAB47BC), // Purple
    const Color(0xFF42A5F5), // Blue
  ];
  List<Color> _targetPaletteColors = [
    const Color(0xFFF06292),
    const Color(0xFFAB47BC),
    const Color(0xFF42A5F5),
  ];
  late AnimationController _animationController;
  final math.Random _random = math.Random();
  final blobAnimDuration = Duration(milliseconds: 400); // o el valor que prefieras
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _updateColors();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateColors() async {
    final currentSong = widget.songs[_currentIndex];
    final imageUrl = currentSong['image'] ?? '';

    if (imageUrl.isNotEmpty) {
      try {
        // Usar isolate para el procesamiento pesado
        var cache = DefaultCacheManager();
        File file = await cache.getSingleFile(imageUrl);
        var port = ReceivePort();
        var isolate = await FlutterIsolate.spawn(
          computePalette,
          [file.readAsBytesSync(), port.sendPort],
        );

        port.listen((msg) {
          if (msg is List<int>) {
            List<Color> colors = msg.map((d) => Color(d)).toList();
            
            if (colors.isNotEmpty) {
              setState(() {
                _targetPaletteColors = colors;
                _paletteColors.clear();
                _paletteColors.addAll(colors);
              });
            } else {
              setState(() {
                _targetPaletteColors = [
                  const Color(0xFFF06292),
                  const Color(0xFFAB47BC),
                  const Color(0xFF42A5F5),
                ];
                _paletteColors.clear();
                _paletteColors.addAll(_targetPaletteColors);
              });
            }
          }
          
          isolate.kill();
          port.close();
        });
      } catch (e) {
        print('Error extracting colors: $e');
        setState(() {
          _targetPaletteColors = [
            const Color(0xFFF06292),
            const Color(0xFFAB47BC),
            const Color(0xFF42A5F5),
          ];
          _paletteColors.clear();
          _paletteColors.addAll(_targetPaletteColors);
        });
      }
    }
  }

  void _nextSong() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.songs.length;
    });
    _updateColors();
  }
  
  void _previousSong() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.songs.length) % widget.songs.length;
    });
    _updateColors();
  }

  Widget _buildBlurryBlobBackground() {
    final size = MediaQuery.of(context).size;
    final blobsCount = 18; // Más blobs
    final random = math.Random(_currentIndex);

    // Genera una lista extendida de colores mezclando los de la paleta
    List<Color> extendedColors = [];
    for (int i = 0; i < _targetPaletteColors.length; i++) {
      extendedColors.add(_targetPaletteColors[i]);
      // Mezcla con el siguiente color (circular)
      final nextColor = _targetPaletteColors[(i + 1) % _targetPaletteColors.length];
      extendedColors.add(Color.lerp(_targetPaletteColors[i], nextColor, 0.5)!);
    }

    List<Widget> blobs = List.generate(blobsCount, (i) {
      final color = extendedColors[i % extendedColors.length].withOpacity(0.28 + random.nextDouble() * 0.22);
      // Permite blobs fuera de la pantalla para cubrir bordes
      final alignment = Alignment(
        -1.3 + 2.6 * random.nextDouble(), // de -1.3 a 1.3
        -1.3 + 2.6 * random.nextDouble(),
      );
      final sizeFactor = 0.7 + random.nextDouble() * 1.1; // entre 0.7 y 1.8
      final blobSize = size.width * sizeFactor;

      return AnimatedAlign(
        duration: const Duration(milliseconds: 900),
        alignment: alignment,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          width: blobSize,
          height: blobSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      );
    });

    // Color base de fondo (mezcla de todos los colores)
    final baseColor = _targetPaletteColors
        .reduce((a, b) => Color.lerp(a, b, 0.5)!)
        .withOpacity(0.7);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: baseColor,
        ),
        ...blobs,
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 160, sigmaY: 160), // Más blur
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final currentSong = widget.songs[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: FriendHeader(
            profilePicUrl: widget.profilePicUrl,
            name: widget.name,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBlurryBlobBackground(),
          // Capa de gestos encima de todo menos el AppBar
          Positioned.fill(
            top: kToolbarHeight, // deja libre el AppBar
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.localPosition.dx < screenWidth / 2) {
                  _previousSong();
                } else {
                  _nextSong();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          // Contenido principal
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.songs.length > 2)
                      Transform.translate(
                        offset: const Offset(40, -20),
                        child: Transform.scale(
                          scale: 0.9,
                          child: _buildArtwork(widget.songs[(_currentIndex + 2) % widget.songs.length]['image'] ?? '', opacity: 0.7),
                        ),
                      ),
                    if (widget.songs.length > 1)
                      Transform.translate(
                        offset: const Offset(20, -10),
                        child: Transform.scale(
                          scale: 0.95,
                          child: _buildArtwork(widget.songs[(_currentIndex + 1) % widget.songs.length]['image'] ?? '', opacity: 0.8),
                        ),
                      ),
                    // AnimatedSwitcher para el artwork principal
                    AnimatedSwitcher(
                      duration: blobAnimDuration,
                      child: _buildArtwork(
                        currentSong['image'] ?? '',
                        opacity: 1.0,
                        key: ValueKey(currentSong['image']),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Text(
                  currentSong['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  currentSong['artist'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(String imageUrl, {double opacity = 1.0, Key? key}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 35, 35, 35),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color.fromARGB(255, 35, 35, 35),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 80,
                      ),
                    );
                  },
                )
              : const Icon(
                  Icons.music_note,
                  color: Colors.white54,
                  size: 80,
                ),
        ),
      ),
    );
  }
}