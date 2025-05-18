import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class SpotifyAuthWebView extends StatefulWidget {
  final WebViewController controller;
  final VoidCallback onClose;
  final bool isLoading;

  const SpotifyAuthWebView({
    Key? key,
    required this.controller,
    required this.onClose,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<SpotifyAuthWebView> createState() => _SpotifyAuthWebViewState();
}

class _SpotifyAuthWebViewState extends State<SpotifyAuthWebView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isClosing = false;

  void _restoreSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromARGB(255, 33, 33, 33),
        systemNavigationBarDividerColor: Color.fromARGB(255, 33, 33, 33),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _handleClose() async {
    setState(() {
      _isClosing = true;
    });
    
    _restoreSystemUI();
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF111111),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF111111),
        systemNavigationBarDividerColor: Color(0xFF111111),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _restoreSystemUI();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                if (widget.isLoading)
                  LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(controller: widget.controller),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ClipOval(
                          child: Material(
                            color: Colors.black.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _isClosing ? null : _handleClose,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 