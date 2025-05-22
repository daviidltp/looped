import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/spotify_auth_screen.dart';
import 'screens/tabs_screen.dart';
import 'services/auth_service.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await AuthService.isAuthenticated();
    if (mounted) {
      setState(() {
        _isAuthenticated = isAuth;
        _isLoading = false;
      });
    }
  }

  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'looped',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<bool>(
              future: AuthService.isAuthenticated(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingScreen();
                }
                final isAuth = snapshot.data ?? false;
                return isAuth
                    ? const TabsScreen()
                    : SpotifyAuthScreen(onAuth: _onAuthenticated);
              },
            ),
          );
        }
        return null;
      },
      routes: {
        '/welcome': (context) => WelcomeScreen(onEnter: _onAuthenticated),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
