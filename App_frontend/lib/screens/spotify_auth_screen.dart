import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'tabs_screen.dart';
import '../services/auth_service.dart';
import '../screens/spotify_auth_webview.dart';
import '../services/track_service.dart';
import 'loop_auth_background.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/navigation_utils.dart';

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
                Navigator.of(context).pop();
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

  Future<void> _openWebView() async {
    await NavigationUtils.pushCupertino(
      context,
      SpotifyAuthWebView(
        controller: _webViewController!,
        onClose: () {
          Navigator.of(context).pop();
          setState(() {
            _showWebView = false;
            _isLoading = false;
          });
        },
        isLoading: _isLoading,
      ),
    );
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
      _openWebView();
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
      await AuthService.saveSpotifyToken(token);
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
          // Replace the old background with AuthLoopBackground
          const AuthLoopBackground(),
          

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
                      // Logo
                      Padding(
                        padding: const EdgeInsets.only(top: 150.0,),
                        child: LoopedLogo(logoSize: logoSize, circleSize: circleSize),
                      ),
                      const SizedBox(height: 0),
                      // Título y slogan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: const LoopedTitle(),
                      ),
                      const SizedBox(height: 32),
                      // Error message if any
                      if (_errorMessage != null)
                        ErrorMessage(message: _errorMessage!),
                      const Spacer(),
                      // Bottom section with button
                      BottomSection(
                        isLoading: _isLoading,
                        showWebView: _showWebView,
                        onAuthPressed: _authenticateWithSpotify,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

// Nuevo widget: Logo con efectos
class LoopedLogo extends StatelessWidget {
  final double logoSize;
  final double circleSize;
  const LoopedLogo({super.key, required this.logoSize, required this.circleSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sombra
        Container(
          width: circleSize * 0.75,
          height: circleSize * 0.75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                blurRadius: 60,
                spreadRadius: 30,
              ),
            ],
          ),
        ),
        // Glow
        Container(
          width: circleSize * 2.4,
          height: circleSize * 1.3,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: ClipOval(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Color.fromARGB(0, 255, 255, 255), BlendMode.srcIn),
                  child: Image.asset(
                    'assets/logo_final.png',
                    width: logoSize * 1.2,
                    height: logoSize * 1.2,
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
          ),
        ),
        // Logo principal
        Container(
          width: circleSize * 1.6,
          height: circleSize * 0.8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                'assets/logo_white.png',
                width: logoSize * 1.2,
                height: logoSize * 1.2,
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
    );
  }
}

// Nuevo widget: Título y slogan
class LoopedTitle extends StatelessWidget {
  const LoopedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'looped',
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 56,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tus bucles de la semana.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const Text(
          'Otra vez. Y otra.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// Nuevo widget: Mensaje de error
class ErrorMessage extends StatelessWidget {
  final String message;
  const ErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Nuevo widget: Botón de autenticación
class SpotifyAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SpotifyAuthButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        onPressed: onPressed,
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
    );
  }
}

// Nuevo widget: Sección inferior
class BottomSection extends StatelessWidget {
  final bool isLoading;
  final bool showWebView;
  final VoidCallback onAuthPressed;
  const BottomSection({
    super.key,
    required this.isLoading,
    required this.showWebView,
    required this.onAuthPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 48,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLoading)
            SpotifyAuthButton(onPressed: onAuthPressed),
          if (isLoading && !showWebView)
            const Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
        ],
      ),
    );
  }
}