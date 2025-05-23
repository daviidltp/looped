import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:looped/components/home/friend_top_songs_row.dart';

class FriendCarouselElement extends StatefulWidget {
  final List<Map<String, String>> songs;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const FriendCarouselElement({
    super.key,
    required this.songs,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<FriendCarouselElement> createState() => _FriendCarouselElementState();
}

class _FriendCarouselElementState extends State<FriendCarouselElement> {
  late CarouselSliderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: _controller,
      options: CarouselOptions(
        height: 500,
        initialPage: widget.currentIndex,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        viewportFraction: 1.0,
        autoPlay: false,
        onPageChanged: (index, reason) {
          widget.onPageChanged(index);
        },
      ),
      items: [
        SongCard(song: widget.songs[0]),
        SongCard(song: widget.songs.length > 1 ? widget.songs[1] : widget.songs[0]),
        SongCard(song: widget.songs.length > 2 ? widget.songs[2] : widget.songs[0]),
        // Cuarto elemento: FriendTopSongsRow
        Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  height: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 12),
                      FriendTopSongsRow(
                        songs: widget.songs,
                        name: "Top canciones de ${widget.songs.isNotEmpty ? widget.songs[0]['artist'] ?? '' : ''}",
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 2,
                          ),
                          icon: SvgPicture.asset(
                            'assets/icons/spotify.svg',
                            width: 28,
                            height: 28,
                            color: Colors.black,
                          ),
                          label: const Text(
                            "Añadir a tu playlist",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            // Acción al pulsar el botón
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Nuevo widget SongCard
class SongCard extends StatelessWidget {
  final Map<String, String> song;

  const SongCard({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 20,
          height: 500,
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
              // Imagen de fondo
              Container(
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
              ),
              // Overlay de gradiente
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black,
                    ],
                  ),
                ),
              ),
              // Overlay oscuro para mejorar contraste
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.25),
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
              // Título y artista (bajado un poco)
              Align(
                alignment: const Alignment(0, 0.55),
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
              // Botones de acción (bajados un poco)
              Align(
                alignment: const Alignment(0, 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/spotify.svg',
                        width: 32,
                        height: 32,
                        color: Colors.white70,
                      ),
                      onPressed: () {},
                    ),
                    
                    const SizedBox(width: 28),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow_rounded, color: Color.fromARGB(255, 0, 0, 0), size: 38),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 28),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white70, size: 32),
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
  }
}



