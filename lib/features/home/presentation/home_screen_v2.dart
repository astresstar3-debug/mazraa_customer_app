import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/presentation/marketplace_screens.dart';
import '../../auctions/presentation/auction_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final products = app.products;
    final auctions = app.auctions;
    final featuredCount = products.length < 4 ? products.length : 4;
    final gridCount = products.length < 6 ? products.length : 6;

    return Scaffold(
      appBar: MazraaAppBar(
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Badge(
              smallSize: 7,
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
        leading: TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/location'),
          icon: const Icon(Icons.location_on_rounded, size: 17),
          label: Text(app.location, style: const TextStyle(fontSize: 11)),
        ),
      ),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSearchField(
              readOnly: true,
              onTap: () => Navigator.pushNamed(context, '/search'),
            ),
            if (app.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (app.errorMessage != null && products.isEmpty) ...[
              const SizedBox(height: 12),
              AppSurfaceCard(
                child: Column(
                  children: [
                    Text(app.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: app.initialize,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickCategory(
                  icon: Icons.gavel_rounded,
                  label: 'المزادات',
                  color: AppColors.forest,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuctionListScreen(),
                    ),
                  ),
                ),
                _QuickCategory(
                  icon: Icons.shopping_cart_outlined,
                  label: 'التسوق',
                  color: AppColors.terracotta,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListScreen(),
                    ),
                  ),
                ),
                _QuickCategory(
                  icon: Icons.pets_rounded,
                  label: 'حيوانات',
                  color: AppColors.forest,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListScreen(title: 'حيوانات'),
                    ),
                  ),
                ),
                _QuickCategory(
                  icon: Icons.eco_rounded,
                  label: 'زراعة',
                  color: AppColors.forest,
                  onTap: () => Navigator.pushNamed(context, '/categories'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SectionHeader(
              title: 'المزادات الحية',
              icon: Icons.gavel_rounded,
              onAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuctionListScreen()),
              ),
            ),
            SizedBox(
              height: 190,
              child: auctions.isEmpty
                  ? const Center(child: Text('لا توجد مزادات متاحة حاليًا'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: auctions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 9),
                      itemBuilder: (context, index) => SizedBox(
                        width: 116,
                        child: AuctionCard(
                          auction: auctions[index],
                          compact: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AuctionDetailsScreen(
                                auction: auctions[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/coupon'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 74,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.forestDark,
                      AppColors.forest,
                      AppColors.terracotta,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كوبون خصم خاص لك',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'احصل على خصم 10% على جميع المنتجات',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(label: 'HA10', color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SectionHeader(
              title: 'العروض المميزة',
              icon: Icons.sell_outlined,
              onAll: () => Navigator.pushNamed(context, '/offers'),
            ),
            SizedBox(
              height: 188,
              child: products.isEmpty
                  ? const Center(child: Text('لا توجد منتجات متاحة حاليًا'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredCount,
                      separatorBuilder: (_, _) => const SizedBox(width: 9),
                      itemBuilder: (context, index) => SizedBox(
                        width: 122,
                        child: ProductCard(
                          product: products[index],
                          onTap: () => _openProduct(context, products[index]),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            SectionHeader(
              title: 'الأكثر مبيعًا',
              icon: Icons.trending_up_rounded,
              onAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductListScreen()),
              ),
            ),
            SizedBox(
              height: 188,
              child: products.isEmpty
                  ? const Center(child: Text('لا توجد منتجات متاحة حاليًا'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredCount,
                      separatorBuilder: (_, _) => const SizedBox(width: 9),
                      itemBuilder: (context, index) => SizedBox(
                        width: 122,
                        child: ProductCard(
                          product: products[index],
                          onTap: () => _openProduct(context, products[index]),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            SectionHeader(
              title: 'جميع المنتجات',
              icon: Icons.grid_view_rounded,
              onAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductListScreen()),
              ),
            ),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Center(child: Text('لا توجد منتجات متاحة حاليًا')),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .62,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: gridCount,
                itemBuilder: (context, index) => ProductCard(
                  product: products[index],
                  onTap: () => _openProduct(context, products[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openProduct(BuildContext context, product) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
  );
}

class _QuickCategory extends StatelessWidget {
  const _QuickCategory({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 23),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
