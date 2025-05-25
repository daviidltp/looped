import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../screens/settings_screen.dart';
import '../../data/users_data.dart';

class ProfileHeader extends StatelessWidget {
  static const String bannerUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRk84CCrcc6w3YeE2xGC_V5_CIqJF2EdwzAbA&s';
  static const String defaultProfilePicUrl = 'https://img.freepik.com/foto-gratis/fondo-oscuro-abstracto_1048-1920.jpg?semt=ais_hybrid&w=740';
  static const String defaultName = 'David Lopez';
  static const String defaultUsername = 'david';
  static const String description = 'Hola chavales';
  static const String followersDefault = '5,121';
  static const String followingDefault = '2,288';
  static const String totalPlaysDefault = '3,500';

  final bool isCurrentUser;
  final Map<String, dynamic> user;
  final bool? isFriend;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onEditProfile;
  final List<String> labels;

  const ProfileHeader({
    super.key,
    required this.user,
    this.isCurrentUser = true,
    this.isFriend,
    this.onToggleFollow,
    this.onEditProfile,
    this.labels = const [],
  });

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
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar centrado
          Center(
            child: CircleAvatar(
              radius: 64,
              backgroundColor: theme.scaffoldBackgroundColor,
              child: CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(user['profilePic'] ?? defaultProfilePicUrl),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nombre y verificado centrado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user['name'] ?? defaultName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (user['verificado'] == true) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Colors.blue, size: 20),
              ],
            ],
          ),
          if ((user['descripcion'] ?? description).toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Center(
                // child: Text(
                //   user['descripcion'] ?? description,
                //   style: const TextStyle(
                //     fontSize: 14,
                //     color: Colors.white70,
                //   ),
                //   maxLines: 5,
                //   textAlign: TextAlign.center,
                // ),
              ),
            ),
          // Etiquetas debajo de la descripción
          
          // Stats centrados
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Seguidores', user['followers']?.toString() ?? followersDefault, center: true),
              const SizedBox(width: 32),
              _buildStatItem('Siguiendo', user['following']?.toString() ?? followingDefault, center: true),
            ],
          ),
          
          if (labels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
              child: SizedBox(
                width: 320,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: labels.map((label) => ProfileLabelChip(label: label)).toList(),
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Botón de acción
          if (isCurrentUser)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},//onEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 44),
                ),
                child: const Text(
                  'Editar perfil',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          if (!isCurrentUser && isFriend != null && onToggleFollow != null)
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onToggleFollow,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isFriend! ? Colors.black : Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      isFriend! ? 'Siguiendo' : 'Seguir',
                      style: TextStyle(
                        color: isFriend! ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool center = false}) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          _formatNumber(value),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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

  String _formatNumber(String numberStr) {
    // Remove any commas from the string and parse to int
    int number = int.tryParse(numberStr.replaceAll(',', '')) ?? 0;
    
    if (number < 10000) {
      // For numbers less than 10k, return as is
      return number.toString();
    } else if (number < 1000000) {
      // For numbers between 10k and 1M, format as K
      double value = number / 1000;
      return value >= 100 ? '${value.toInt()}K' : '${value.toStringAsFixed(1)}K';
    } else {
      // For numbers 1M and above, format as M
      double value = number / 1000000;
      return value >= 10 ? '${value.toInt()}M' : '${value.toStringAsFixed(1)}M';
    }
  }
}

// Nuevo widget para las etiquetas
class ProfileLabelChip extends StatelessWidget {
  final String label;
  const ProfileLabelChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
        // Sin borde
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}