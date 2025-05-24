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

  const ProfileHeader({
    super.key,
    required this.user,
    this.isCurrentUser = true,
    this.isFriend,
    this.onToggleFollow,
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
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila: Avatar + Nombre y descripción
          Row(
            crossAxisAlignment: (user['descripcion'] ?? description).toString().isEmpty 
                ? CrossAxisAlignment.center 
                : CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.scaffoldBackgroundColor,
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(user['profilePic'] ?? defaultProfilePicUrl),
                ),
              ),
              const SizedBox(width: 16),
              // Nombre, verificado y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        child: Text(
                          user['descripcion'] ?? description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Seguidores', user['followers']?.toString() ?? followersDefault, center: true),
              _buildStatItem('Siguiendo', user['following']?.toString() ?? followingDefault, center: true),
              _buildStatItem('Escuchas', user['totalPlays']?.toString() ?? totalPlaysDefault, center: true),
            ],
          ),
          const SizedBox(height: 16),
          // Botones ocupando todo el ancho
          if (isCurrentUser)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      foregroundColor: Colors.white.withOpacity(0.2),
                    ),
                    child: Text('Editar perfil', 
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToSettings(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: theme.primaryColor.withOpacity(0.7), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text('Ajustes', 
                      style: TextStyle(
                        color: theme.primaryColor, 
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      )
                    ),
                  ),
                ),
              ],
            ),
          // Si no es el usuario actual, mostrar botón de seguir/seguir
          if (!isCurrentUser && isFriend != null && onToggleFollow != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: onToggleFollow,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                          fontSize: 15,
                        ),
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