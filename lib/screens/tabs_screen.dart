import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'profile_screen.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    ProfileScreen(),
  ];

  final List<_NavBarItemData> _navBarItems = const [
    _NavBarItemData(
      icon: Icons.home,
    ),
    _NavBarItemData(
      icon: Icons.person,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // o Brightness.dark según el tema
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color selectedColor = const Color.fromARGB(255, 175, 255, 176).withAlpha((0.1 * 255).toInt());
    final Color splashColor = Theme.of(context).colorScheme.inversePrimary.withAlpha((0.05 * 255).toInt());
    final Color unselectedColor = Theme.of(context).colorScheme.onBackground.withAlpha((0.6 * 255).toInt());
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Container(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            body: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                // Bordes redondeados solo arriba izquierda y arriba derecha
                color: Colors.transparent, // color se pone en el child para mantener el BoxShadow
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 0),
              // Aquí agregamos la sombra blanca al BottomNavigationBar
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05), // Sombra blanca más visible
                      blurRadius: 10,
                      offset: const Offset(0, -1),
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: PhysicalModel(
                  color: backgroundColor,
                  elevation: 0,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: 68,
                        child: Row(
                          children: List.generate(_navBarItems.length, (index) {
                            final item = _navBarItems[index];
                            // Definir el BorderRadius para cada ítem
                            BorderRadius itemRadius;
                            if (index == 0) {
                              // Izquierda: solo arriba izquierda
                              itemRadius = const BorderRadius.only(
                                topLeft: Radius.circular(18),
                              );
                            } else if (index == _navBarItems.length - 1) {
                              // Derecha: solo arriba derecha
                              itemRadius = const BorderRadius.only(
                                topRight: Radius.circular(18),
                              );
                            } else {
                              itemRadius = BorderRadius.zero;
                            }
                            return Expanded(
                              child: _CustomNavBarItem(
                                icon: item.icon,
                                selected: _selectedIndex == index,
                                selectedColor: selectedColor,
                                splashColor: splashColor,
                                unselectedColor: unselectedColor,
                                onTap: () => setState(() => _selectedIndex = index),
                                borderRadius: itemRadius,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
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

class _NavBarItemData {
  final IconData icon;
  const _NavBarItemData({required this.icon});
}

class _CustomNavBarItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final Color splashColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _CustomNavBarItem({
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.splashColor,
    required this.unselectedColor,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconBgColor = selected ? selectedColor : Colors.transparent;
    final Color iconColor = selected ? Colors.white : unselectedColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: splashColor,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}