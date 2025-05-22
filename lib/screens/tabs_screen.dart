import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'profile_screen.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'search_friends_screen.dart';
import '../services/auth_service.dart';
import '../data/users_data.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;

  String? _username;
  String? _profilePic;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _loadProfileData() async {
    final username = await AuthService.getUsername();
    final profilePic = await AuthService.getProfilePic();
    if (mounted) {
      setState(() {
        _username = username;
        _profilePic = profilePic;
      });
    }
  }

  List<Widget> get _pages => [
    const HomeTab(),
    const SearchFriendsScreen(),
    Builder(
      builder: (context) {
        final myuser = usersData.firstWhere(
          (u) => u['username'] == 'david',
          orElse: () => usersData.firstWhere((u) => u['username'] == 'abepe1010'),
        );
        return ProfileScreen(
          user: myuser,
          isCurrentUser: true,
        );
      },
    ),
  ];

  final List<_NavBarItemData> _navBarItems = [
    _NavBarItemData(
      filledIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
      outlinedIcon: PhosphorIcons.house(PhosphorIconsStyle.regular),
    ),
    _NavBarItemData(
      filledIcon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
      outlinedIcon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
    ),
    _NavBarItemData(
      filledIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
      outlinedIcon: PhosphorIcons.user(PhosphorIconsStyle.regular),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color selectedColor = const Color.fromARGB(255, 175, 255, 176).withAlpha((0.1 * 255).toInt());
    final Color splashColor = Theme.of(context).colorScheme.inversePrimary.withAlpha((0.05 * 255).toInt());
    final Color unselectedColor = Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).toInt());
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
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05),
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
                            BorderRadius itemRadius;
                            if (index == 0) {
                              itemRadius = const BorderRadius.only(
                                topLeft: Radius.circular(18),
                              );
                            } else if (index == _navBarItems.length - 1) {
                              itemRadius = const BorderRadius.only(
                                topRight: Radius.circular(18),
                              );
                            } else {
                              itemRadius = BorderRadius.zero;
                            }
                            return Expanded(
                              child: _CustomNavBarItem(
                                filledIcon: item.filledIcon,
                                outlinedIcon: item.outlinedIcon,
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
  final IconData filledIcon;
  final IconData outlinedIcon;
  const _NavBarItemData({required this.filledIcon, required this.outlinedIcon});
}

class _CustomNavBarItem extends StatelessWidget {
  final IconData filledIcon;
  final IconData outlinedIcon;
  final bool selected;
  final Color selectedColor;
  final Color splashColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _CustomNavBarItem({
    required this.filledIcon,
    required this.outlinedIcon,
    required this.selected,
    required this.selectedColor,
    required this.splashColor,
    required this.unselectedColor,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
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
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              selected ? filledIcon : outlinedIcon,
              color: iconColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}