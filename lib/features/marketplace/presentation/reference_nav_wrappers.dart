import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'matched_marketplace_screens.dart';

class FinalCategoriesScreen extends StatelessWidget {
  const FinalCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) => const _NavOverlay(
        child: MatchedCategoriesScreen(),
        middleLabel: 'الأقسام',
        middleIcon: Icons.grid_view_rounded,
        middleRoute: '/categories',
        selected: 2,
      );
}

class FinalSearchScreen extends StatelessWidget {
  const FinalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) => const _NavOverlay(
        child: MatchedSearchScreen(),
        middleLabel: 'البحث',
        middleIcon: Icons.search_rounded,
        middleRoute: '/search',
        selected: 2,
      );
}

class FinalFavoritesScreen extends StatelessWidget {
  const FinalFavoritesScreen({super.key, this.empty = false, this.plantEmpty = false});

  final bool empty;
  final bool plantEmpty;

  @override
  Widget build(BuildContext context) => _NavOverlay(
        child: MatchedFavoritesScreen(empty: empty, plantEmpty: plantEmpty),
        middleLabel: 'المزادات',
        middleIcon: Icons.gavel_outlined,
        middleRoute: '/auctions',
        selected: 0,
      );
}

class _NavOverlay extends StatelessWidget {
  const _NavOverlay({
    required this.child,
    required this.middleLabel,
    required this.middleIcon,
    required this.middleRoute,
    required this.selected,
  });

  final Widget child;
  final String middleLabel;
  final IconData middleIcon;
  final String middleRoute;
  final int selected;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: _MatchedReferenceNav(
              middleLabel: middleLabel,
              middleIcon: middleIcon,
              middleRoute: middleRoute,
              selected: selected,
            ),
          ),
        ],
      );
}

class _MatchedReferenceNav extends StatelessWidget {
  const _MatchedReferenceNav({
    required this.middleLabel,
    required this.middleIcon,
    required this.middleRoute,
    required this.selected,
  });

  final String middleLabel;
  final IconData middleIcon;
  final String middleRoute;
  final int selected;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, IconData icon, String route})>[
      (label: 'الرئيسية', icon: Icons.home_outlined, route: '/'),
      (label: 'المنتجات', icon: Icons.grid_view_outlined, route: '/products'),
      (label: middleLabel, icon: middleIcon, route: middleRoute),
      (label: 'سلة التسوق', icon: Icons.shopping_cart_outlined, route: '/cart'),
      (label: 'حسابي', icon: Icons.person_outline_rounded, route: '/account'),
    ];

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final active = index == selected;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (active) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      item.route,
                      (route) => item.route != '/' && route.isFirst,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: active ? AppColors.forest : AppColors.muted,
                        size: 23,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: active ? AppColors.forest : AppColors.muted,
                          fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: active ? 25 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
