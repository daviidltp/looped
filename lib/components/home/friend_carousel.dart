import 'package:flutter/material.dart';
import 'friend_artwork_element.dart';
import 'friend_description.dart';
import 'dart:math';
import 'dart:ui';
import 'package:palette_generator/palette_generator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import 'friend_carousel_element.dart';

class FriendCarousel extends StatefulWidget {
  final List<Map<String, String>> songs; // Cada canción debe tener 'image', 'title', 'artist', 'plays'
  final String? description; // Descripción general sobre los bucles
  final String profilePicUrl;
  final String name;
  
  const FriendCarousel({
    super.key, 
    required this.songs,
    this.description,
    required this.profilePicUrl,
    required this.name,
  });

  @override
  State<FriendCarousel> createState() => _FriendCarouselState();
}

class _FriendCarouselState extends State<FriendCarousel> {
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.description != null && widget.description!.isNotEmpty)
            FriendDescription(description: widget.description!),
          FriendCarouselElement(songs: widget.songs),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.songs.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.white : Colors.white38,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
