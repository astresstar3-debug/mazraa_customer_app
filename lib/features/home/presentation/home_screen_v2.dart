import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../auctions/presentation/connected_auction_screens.dart';
import '../../cart/data/coupon_repository.dart';
import '../../cart/domain/coupon.dart';
import '../../cart/presentation/connected_coupons_screen.dart';
import '../../marketplace/presentation/connected_marketplace_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Coupon? featuredCoupon;
  bool _couponRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_couponRequested) {
      _couponRequested = true;
      _loadFeaturedCoupon();
    }
  }

  Future<void> _loadFeaturedCoupon() async {
    try {
      final coupons = await CouponRepository(AppScope.of(context).client).getCoupons();
      if (!mounted || coupons.isEmpty) return;
      setState(() => featuredCoupon = coupons.first);
    } catch (_) {
      // The home screen remains fully usable when coupons are unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final products = app.products;
    final auctions = app.auctions;
    final discounted = products.where((p) => p.discount != null).toList()
      ..sort((a, b) => (b.discount ?? 0).compareTo(a.discount ?? 0));
    final featuredProducts = discounted.isEmpty ? products : discounted;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 5, 14, 3),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: app.location.isEmpty
                        ? const SizedBox.shrink()
                        : TextButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/location'),
                            icon: const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                            ),
                            label: Text(
                              app.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                  const Expanded(
                    child: Center(child: AppLogo(size: 48)),
                  ),
                  SizedBox(
                    width: 112,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'الإشعارات',
                        onPressed: () =>
                            Navigator.pushNamed(context, '/notifications'),
                        icon: const Badge(
                          smallSize: 7,
                          child: Icon(Icons.notifications_none_rounded),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 14, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSearchField(
              readOnly: true,
              onTap: () => Navigator.pushNamed(context, '/search'),
            ),
            if (app.isLoading) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (app.errorMessage != null && products.isEmpty && auctions.isEmpty) ...[
              const SizedBox(height: 10),
              _CompactMessage(
                icon: Icons.cloud_off_rounded,
                message: app.errorMessage!,
                actionLabel: 'إعادة المحاولة',
                onAction: app.initialize,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _QuickCategory(
                  icon: Icons.gavel_rounded,
                  label: 'المزادات',
                  color: AppColors.forestDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectedAuctionListScreen(),
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
                      builder: (_) => const ConnectedProductListScreen(),
                    ),
                  ),
                ),
                _QuickCategory(
                  icon: Icons.pets_rounded,
                  label: 'حيوانات',
                  color: Theme.of(context).colorScheme.surface,
                  foreground: AppColors.forestDark,
                  outlined: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectedProductListScreen(
                        title: 'حيوانات',
                      ),
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
            const SizedBox(height: 16),
            _AuctionSection(auctions: auctions),
            if (featuredCoupon != null) ...[
              const SizedBox(height: 16),
              SectionHeader(
                title: 'الكوبونات',
                icon: Icons.local_activity_outlined,
                onAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConnectedCouponsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _HomeCouponBanner(coupon: featuredCoupon!),
            ],
            const SizedBox(height: 16),
            _ProductSection(
              title: 'العروض المميزة',
              icon: Icons.sell_outlined,
              products: featuredProducts,
              onAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConnectedProductListScreen(
                    title: 'العروض',
                    onlyOffers: true,
                  ),
                ),
              ),
              onProduct: (product) => _openProduct(context, product),
            ),
            const SizedBox(height: 16),
            _ProductSection(
              title: 'الأكثر مبيعًا',
              icon: Icons.workspace_premium_outlined,
              products: products,
              onAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConnectedProductListScreen(),
                ),
              ),
              onProduct: (product) => _openProduct(context, product),
            ),
            const SizedBox(height: 16),
            SectionHeader(
              title: 'جميع المنتجات',
              icon: Icons.grid_view_rounded,
              onAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConnectedProductListScreen(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (products.isEmpty)
              const _CompactMessage(
                icon: Icons.inventory_2_outlined,
                message: 'لا توجد منتجات متاحة حاليًا',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .66,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: products.length < 6 ? products.length : 6,
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
        MaterialPageRoute(
          builder: (_) => ConnectedProductDetailsScreen(product: product),
        ),
      );
}

class _AuctionSection extends StatelessWidget {
  const _AuctionSection({required this.auctions});

  final List<dynamic> auctions;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F1DE),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            SectionHeader(
              title: 'المزادات الحية',
              icon: Icons.gavel_rounded,
              onAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConnectedAuctionListScreen(),
                ),
              ),
            ),
            const SizedBox(height: 7),
            if (auctions.isEmpty)
              const _CompactMessage(
                icon: Icons.gavel_outlined,
                message: 'لا توجد مزادات حية حاليًا',
                embedded: true,
              )
            else
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: auctions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 9),
                  itemBuilder: (context, index) => SizedBox(
                    width: 122,
                    child: AuctionCard(
                      auction: auctions[index],
                      compact: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectedAuctionDetailsScreen(
                            auction: auctions[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _HomeCouponBanner extends StatelessWidget {
  const _HomeCouponBanner({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConnectedCouponsScreen(couponId: coupon.id),
          ),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 86,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Color(0xFF0C4B2A),
                AppColors.forest,
                AppColors.terracotta,
              ],
              stops: [0, .72, 1],
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.local_activity_rounded,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.name.isEmpty ? 'كوبون خصم خاص بك' : coupon.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'احصل على خصم ${coupon.discountLabel}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(end: 14),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  coupon.code,
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.icon,
    required this.products,
    required this.onAll,
    required this.onProduct,
  });

  final String title;
  final IconData icon;
  final List<dynamic> products;
  final VoidCallback onAll;
  final ValueChanged<dynamic> onProduct;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SectionHeader(title: title, icon: icon, onAll: onAll),
          const SizedBox(height: 8),
          if (products.isEmpty)
            const _CompactMessage(
              icon: Icons.local_offer_outlined,
              message: 'لا توجد منتجات متاحة في هذا القسم حاليًا',
            )
          else
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length < 4 ? products.length : 4,
                separatorBuilder: (_, _) => const SizedBox(width: 9),
                itemBuilder: (context, index) => SizedBox(
                  width: 126,
                  child: ProductCard(
                    product: products[index],
                    onTap: () => onProduct(products[index]),
                  ),
                ),
              ),
            ),
        ],
      );
}

class _CompactMessage extends StatelessWidget {
  const _CompactMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.embedded = false,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.forestSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.forest, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
    if (embedded) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(13),
        ),
        child: child,
      );
    }
    return AppSurfaceCard(padding: const EdgeInsets.all(10), child: child);
  }
}

class _QuickCategory extends StatelessWidget {
  const _QuickCategory({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.foreground = Colors.white,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 3),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border: outlined
                        ? Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: .45),
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(child: Icon(icon, color: foreground, size: 29)),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
