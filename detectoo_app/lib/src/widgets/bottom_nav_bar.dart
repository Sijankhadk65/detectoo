import 'package:flutter/material.dart';

import '../routes.dart';
import '../screens/home_screen.dart';
import '../screens/plants_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';

/// Main navigation shell with a floating bottom-nav capsule.
///
/// The bar matches the design system: a white capsule floating off the
/// bottom edge with a soft shadow, an active tab rendered as a dark-green
/// pill with a white glyph, and a raised terracotta SCAN button at the
/// centre that opens [AddPlantScreen] for photo-based identification.
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    PlantsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _FloatingNav(
        currentIndex: _currentIndex,
        onSelect: (index) => setState(() => _currentIndex = index),
        onScan: () => Navigator.pushNamed(context, Routes.addPlant),
      ),
    );
  }
}

/// The floating white capsule that hosts the nav items and the SCAN button.
class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.currentIndex,
    required this.onSelect,
    required this.onScan,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: DetectooColors.surfaceWhite,
            borderRadius: BorderRadius.circular(DetectooRadii.xl2),
            boxShadow: DetectooShadows.nav,
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onSelect(0),
              ),
              _NavItem(
                icon: Icons.spa_outlined,
                activeIcon: Icons.spa_rounded,
                label: 'Plants',
                selected: currentIndex == 1,
                onTap: () => onSelect(1),
              ),
              _ScanButton(onTap: onScan),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                selected: currentIndex == 2,
                onTap: () => onSelect(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single nav destination. Active state is a dark-green rounded pill.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DetectooRadii.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? DetectooColors.green600 : Colors.transparent,
            borderRadius: BorderRadius.circular(DetectooRadii.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected ? Colors.white : DetectooColors.textMuted,
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: DetectooText.eyebrow.copyWith(
                  fontSize: 8.5,
                  letterSpacing: 0.6,
                  color: selected ? Colors.white : DetectooColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The raised terracotta SCAN button at the centre of the nav.
class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            transform: Matrix4.translationValues(0, -14, 0),
            decoration: BoxDecoration(
              color: DetectooColors.terracotta,
              shape: BoxShape.circle,
              border: Border.all(color: DetectooColors.surfaceWhite, width: 4),
              boxShadow: DetectooShadows.fab,
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
