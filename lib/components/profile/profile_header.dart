import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../screens/settings_screen.dart';

class ProfileHeader extends StatelessWidget {
  static const String bannerUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRk84CCrcc6w3YeE2xGC_V5_CIqJF2EdwzAbA&s';
  static const String profilePicUrl = 'https://yt3.googleusercontent.com/lUkgGqUdmDu6JlftN606h8O9lNpH_9sFX6xR5VnVOV6Usbv-2SNz5GRCit5C4wdJLIsAfClZ=s900-c-k-c0x00ffffff-no-rj';
  static const String name = 'Pedro D. Quevedo';
  static const String username = '@quevedo';
  static const String description = 'Buenas noches';
  static const String followers = '32K';
  static const String following = '2,288';

  const ProfileHeader({Key? key}) : super(key: key);

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Banner de fondo
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(bannerUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Avatar superpuesto
              Positioned(
                left: 24,
                bottom: -40,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(profilePicUrl),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.verified, color: Colors.green, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem('Followers', followers),
                    const SizedBox(width: 24),
                    _buildStatItem('Following', following),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text('Editar perfil', 
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToSettings(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.primaryColor.withOpacity(0.7), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings, color: theme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text('Ajustes', 
                              style: TextStyle(
                                color: theme.primaryColor, 
                                fontWeight: FontWeight.w600
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}