import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'tabs_screen.dart';
import '../services/auth_service.dart';
import '../widgets/spotify_auth_webview.dart';

class SpotifyAuthScreen extends StatefulWidget {
  final VoidCallback? onAuth;
  const SpotifyAuthScreen({Key? key, this.onAuth}) : super(key: key);

  @override
  State<SpotifyAuthScreen> createState() => _SpotifyAuthScreenState();
}

class _SpotifyAuthScreenState extends State<SpotifyAuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  TextEditingController _tokenController = TextEditingController();
  bool _showWebView = false;
  WebViewController? _webViewController;
  String? _state;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    _checkAuth();
    // Make navigation bar transparent
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

  @override
  void dispose() {
    // Restore navigation bar color when leaving this screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
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
      _state = _generateRandomString(16); // Generar estado único
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
      // Save token
      await AuthService.saveToken(token);
      
      
      // Get top tracks
      await AuthService.fetchTopTracks(token);
      
      // Get recently played tracks
      await AuthService.fetchRecentlyPlayed(token);
      
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: _showWebView
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
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          const Text(
                            'Looped',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/logo.png',
                            width: 150,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 150,
                              height: 150,
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
                              child: Icon(
                                Icons.music_note,
                                size: 80,
                                color: Colors.white,
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
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    
                    // Bottom section with button
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!_isLoading)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: _authenticateWithSpotify,
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.inversePrimary,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/spotify.svg',
                                          semanticsLabel: 'Spotify Logo',
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Connect with Spotify',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (_isLoading && !_showWebView)
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}