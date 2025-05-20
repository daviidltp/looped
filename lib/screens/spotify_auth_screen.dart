import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'tabs_screen.dart';
import '../services/auth_service.dart';
import '../widgets/spotify_auth_webview.dart';
import '../services/track_service.dart';

class SpotifyAuthScreen extends StatefulWidget {
  final VoidCallback? onAuth;
  const SpotifyAuthScreen({super.key, this.onAuth});

  @override
  State<SpotifyAuthScreen> createState() => _SpotifyAuthScreenState();
}

class _SpotifyAuthScreenState extends State<SpotifyAuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _tokenController = TextEditingController();
  bool _showWebView = false;
  WebViewController? _webViewController;
  String? _state;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    _checkAuth();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromARGB(255, 0, 0, 0),
        systemNavigationBarDividerColor: Color.fromARGB(255, 0, 0, 0),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0x00000000),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _tokenController.dispose();
    super.dispose();
  }

  // Check if already authenticated
  Future<void> _checkAuth() async {
    setState(() {
      _isLoading = true;
    });

    final isAuthenticated = await AuthService.isAuthenticated();
    if (isAuthenticated) {
      if (widget.onAuth != null) {
        widget.onAuth!();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Generate a random string for the state parameter
  String _generateRandomString(int length) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            print('Redirect URL: ${request.url}');
            if (request.url.startsWith(AuthService.redirectUri)) {
              Uri uri = Uri.parse(request.url);
              String? code = uri.queryParameters['code'];
              String? error = uri.queryParameters['error'];
              String? returnedState = uri.queryParameters['state'];

              if (error != null) {
                setState(() {
                  _errorMessage = 'Error al autenticar: $error';
                  _showWebView = false;
                  _isLoading = false;
                });
              } else if (code != null && returnedState == _state) {
                print('Código obtenido: $code');
                _processAuthCode(code);
                setState(() {
                  _showWebView = false;
                });
              } else {
                setState(() {
                  _errorMessage = 'Error: Código no encontrado o estado inválido';
                  _showWebView = false;
                  _isLoading = false;
                });
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = 'Error en WebView: ${error.description}';
              _showWebView = false;
              _isLoading = false;
            });
          },
        ),
      );
  }

  Future<void> _processAuthCode(String code) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.exchangeCodeForToken(code);
    
    if (result != null) {
      // Clear and reload popular tracks
      await TrackService.clearCachedTracks();
      await TrackService.getPopularTracksList();
      
      if (widget.onAuth != null) {
        widget.onAuth!();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Error al procesar la autenticación';
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateWithSpotify() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _state = _generateRandomString(16);
    });

    try {
      final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
        'client_id': AuthService.clientId,
        'response_type': 'code',
        'redirect_uri': AuthService.redirectUri,
        'scope': AuthService.scope,
        'state': _state,
        'show_dialog': 'true',
      });

      print('Auth URL: $authUrl');
      _webViewController?.loadRequest(authUrl);
      setState(() {
        _showWebView = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error durante la autenticación: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyManualToken(String token) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.saveToken(token);
      await AuthService.fetchTopTracks(token);
      await AuthService.fetchRecentlyPlayed(token);
      await TrackService.clearCachedTracks();
      // Load popular tracks after clearing cache
      await TrackService.getPopularTracksList();
      
      if (widget.onAuth != null) {
        widget.onAuth!();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al verificar el token: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double logoSize = 150;
    final double circleSize = 180;
    return Scaffold(
      body: Stack(
        children: [
          // Background image with rotation
          Transform.translate(
            offset: Offset(0, 0),
            child: Transform.rotate(
              angle: 45 * pi / 180,
              child: Transform.scale(
                scale: 6.0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 3,
                  height: MediaQuery.of(context).size.height * 3,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY:0),
                    child: Image.asset(
                      'assets/background.jpg',
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Black overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.85),
          ),
          // Content
          _showWebView
              ? SpotifyAuthWebView(
                  controller: _webViewController!,
                  onClose: () {
                    setState(() {
                      _showWebView = false;
                      _isLoading = false;
                    });
                  },
                  isLoading: _isLoading,
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Top container with logo and text
                      Container(
                        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                        child: Column(
                          children: [
                            // Logo with 3D effect
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Shadow
                                Container(
                                  width: circleSize * 2.8,
                                  height: circleSize * 2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 60,
                                        spreadRadius: 30,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                      child: ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcATop,
                                        ),
                                        child: Image.asset(
                                          'assets/logo_dark_test.png',
                                          width: logoSize * 2.5,
                                          height: logoSize * 2.5,
                                          fit: BoxFit.cover,
                                          opacity: const AlwaysStoppedAnimation(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Main logo
                                Container(
                                  width: circleSize * 3.6,
                                  height: circleSize * 1.6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                  ),
                                  child: Center(
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/logo_def.png',
                                        width: logoSize * 2.4,
                                        height: logoSize * 2.4,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: logoSize,
                                          height: logoSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.grey.shade800,
                                                Colors.black,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.music_note,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Title with enhanced effect
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 255, 255, 255),
                                    Color.fromARGB(255, 220, 220, 220),
                                    Color.fromARGB(255, 255, 255, 255),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.0, 0.5, 1.0],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Looped',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  height: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Error message if any
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Bottom section with button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 48, left: 24, right: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLoading)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _authenticateWithSpotify,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/spotify.svg',
                                        semanticsLabel: 'Spotify Logo',
                                        height: 28,
                                        width: 28,
                                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Conectar con Spotify',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_isLoading && !_showWebView)
                              const Padding(
                                padding: EdgeInsets.only(top: 24.0),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}