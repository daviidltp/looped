import 'package:flutter/material.dart';

class AuthLoopBackground extends StatefulWidget {
  const AuthLoopBackground({super.key});

  @override
  State<AuthLoopBackground> createState() => AuthLoopBackgroundState();
}

class AuthLoopBackgroundState extends State<AuthLoopBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animationsInitialized) {
      final height = MediaQuery.of(context).size.height;
      _animation1 = Tween<double>(
        begin: -height,
        end: 0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));

      _animation2 = Tween<double>(
        begin: 0,
        end: height,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
      _animationsInitialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // First sliding image
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation1.value),
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    height: screenHeight - 12,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/background_vertical.jpg'),
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Second sliding image
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation2.value),
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    height: screenHeight - 12,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/background_vertical.jpg'),
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Gradient overlay
        ],
      ),
    );
  }
}
