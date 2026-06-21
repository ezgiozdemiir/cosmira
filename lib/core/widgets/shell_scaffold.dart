import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../utils/haptic_utils.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/astrology') || location.startsWith('/horoscope')) {
      return 1;
    }
    if (location.startsWith('/breathwork')) return 2;
    if (location.startsWith('/moon')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: child,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.midnight,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
            HapticUtils.selection();
            switch (i) {
              case 0:
                context.go('/');
              case 1:
                context.go('/astrology');
              case 2:
                context.go('/breathwork');
              case 3:
                context.go('/moon');
              case 4:
                context.go('/profile');
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome),
              label: 'nav_home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.stars),
              label: 'nav_stars'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.air),
              label: 'nav_breathe'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.nightlight_round),
              label: 'nav_moon'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: 'nav_profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
