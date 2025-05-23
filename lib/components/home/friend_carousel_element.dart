import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';

class FriendCarouselElement extends StatefulWidget {
  final List<Map<String, String>> songs;

  const FriendCarouselElement({super.key, required this.songs});

  @override
  State<FriendCarouselElement> createState() => _FriendCarouselElementState();
}

class _FriendCarouselElementState extends State<FriendCarouselElement> {
  late CarouselSliderController _controller;
  late int _currentIndex;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _controller = CarouselSliderController();
    _currentIndex = 0;
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _currentIndex < widget.songs.length - 1) {
        _controller.nextPage();
      } else if (mounted) {
        _controller.animateToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: _controller,
      options: CarouselOptions(
        height: 440,
        initialPage: _currentIndex,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        viewportFraction: 1.0,
        autoPlay: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      items: widget.songs.map((song) {
        return Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Container(
                  width: 340,
                  height: 440,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(song['image'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Overlay oscuro para mejorar contraste
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                      // Círculo translúcido con la imagen
                      Align(
                        alignment: const Alignment(0, -0.6),
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.13),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipOval(
                              child: Image.network(
                                song['image'] ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Título y artista
                      Align(
                        alignment: const Alignment(0, 0.4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              song['title']!,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              song['artist']!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // Botones de acción
                      Align(
                        alignment: const Alignment(0, 0.82),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border, color: Colors.white70, size: 32),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 28),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFF4B1248), size: 38),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 28),
                            IconButton(
                              icon: const Icon(Icons.ios_share, color: Colors.white70, size: 32),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}



