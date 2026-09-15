import 'package:flutter/material.dart';

import '../../core/state/app_controller.dart';
import '../account/presentation/connected_account_screen.dart';
import '../auctions/presentation/auction_screens.dart';
import '../cart/presentation/connected_cart_screens.dart';
import '../home/presentation/home_screen_v2.dart';
import '../marketplace/presentation/marketplace_screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int index = widget.initialIndex;
  late final pages = const [
    HomeScreen(),
    CategoriesScreen(),
    AuctionListScreen(embedded: true),
    ConnectedCartScreen(embedded: true),
    ConnectedAccountScreen(embedded: true),
  ];
  @override
  Widget build(BuildContext context) {
    final count = AppScope.of(context).cartCount;
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'الأقسام',
          ),
          const NavigationDestination(
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel_rounded),
            label: 'المزادات',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'سلة التسوق',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
