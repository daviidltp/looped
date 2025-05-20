import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'spotify_auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Ajustes'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            const SizedBox(height: 20),
            // Sección de Cuenta
            _buildSection(
              context,
              'Cuenta',
              [
                _buildSettingTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Perfil',
                  onTap: () {
                    // TODO: Implementar navegación al perfil
                  },
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  onTap: () {
                    // TODO: Implementar configuración de notificaciones
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sección de Aplicación
            _buildSection(
              context,
              'Aplicación',
              [
                _buildSettingTile(
                  context,
                  icon: Icons.color_lens_outlined,
                  title: 'Apariencia',
                  onTap: () {
                    // TODO: Implementar configuración de tema
                  },
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Idioma',
                  onTap: () {
                    // TODO: Implementar selección de idioma
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sección de Soporte
            _buildSection(
              context,
              'Soporte',
              [
                _buildSettingTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Ayuda',
                  onTap: () {
                    // TODO: Implementar sección de ayuda
                  },
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'Acerca de',
                  onTap: () {
                    // TODO: Implementar información de la app
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Botón de Cerrar Sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton(
                onPressed: () => _showLogoutDialog(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              Navigator.of(ctx).pop();
              // Redirect to the auth screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SpotifyAuthScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}