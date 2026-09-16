import 'package:flutter/material.dart';

import '../../core/state/app_controller.dart';
import '../../core/theme/app_theme.dart';
import '../account/presentation/connected_account_screen.dart';
import '../auctions/presentation/connected_auction_screens.dart';
import '../cart/presentation/connected_cart_screens.dart';
import '../home/presentation/reference_home_screen.dart';
import '../marketplace/presentation/reference_marketplace_screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int index = widget.initialIndex;

  late final pages = const [
    ReferenceHomeScreen(),
    ReferenceProductListScreen(),
    ConnectedAuctionListScreen(embedded: true),
    ConnectedCartScreen(embedded: true),
    ConnectedAccountScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    final count = AppScope.of(context).cartCount;
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: _ReferenceBottomBar(
        index: index,
        cartCount: count,
        onChanged: (value) => setState(() => index = value),
      ),
    );
  }
}

class _ReferenceBottomBar extends StatelessWidget {
  const _ReferenceBottomBar({
    required this.index,
    required this.cartCount,
    required this.onChanged,
  });

  final int index;
  final int cartCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, IconData selected, String label})>[
      (icon: Icons.home_outlined, selected: Icons.home_rounded, label: 'الرئيسية'),
      (icon: Icons.grid_view_outlined, selected: Icons.grid_view_rounded, label: 'المنتجات'),
      (icon: Icons.gavel_outlined, selected: Icons.gavel_rounded, label: 'المزادات'),
      (icon: Icons.shopping_cart_outlined, selected: Icons.shopping_cart_rounded, label: 'سلة التسوق'),
      (icon: Icons.person_outline_rounded, selected: Icons.person_rounded, label: 'حسابي'),
    ];

    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: const Color(0x180D4328),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 67,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(i),
                    child: _NavItem(
                      active: index == i,
                      icon: index == i ? items[i].selected : items[i].icon,
                      label: items[i].label,
                      badge: i == 3 ? cartCount : 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.active,
    required this.icon,
    required this.label,
    required this.badge,
  });

  final bool active;
  final IconData icon;
  final String label;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.forestDark : AppColors.muted;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: active ? 26 : 24),
              if (badge > 0)
                PositionedDirectional(
                  top: -5,
                  end: -12,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 9.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
