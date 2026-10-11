import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MovieLogBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const MovieLogBottomNavBar({super.key, required this.currentIndex});

  static const _destinations = [
    (route: '/home', icon: 'assets/icons/home.svg', label: '홈'),
    (route: '/movies', icon: 'assets/icons/movie.svg', label: '영화'),
    (route: '/my', icon: 'assets/icons/person.svg', label: '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      indicatorColor: AppColors.primaryLight,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        context.go(_destinations[index].route);
      },
      destinations: [
        for (final destination in _destinations)
          NavigationDestination(
            icon: SvgPicture.asset(
              destination.icon,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.textTertiary,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              destination.icon,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            label: destination.label,
          ),
      ],
    );
  }
}
