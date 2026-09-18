import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../auctions/presentation/connected_auction_screens.dart';
import '../../cart/data/coupon_repository.dart';
import '../../cart/domain/coupon.dart';
import '../../cart/presentation/connected_coupons_screen.dart';
import '../../marketplace/domain/marketplace_models.dart';
import '../../marketplace/presentation/unified_product_details_screen.dart';

const bool _visualReferenceMode =
    bool.fromEnvironment('REFERENCE_VISUAL_TEST', defaultValue: false);

class ReferenceHomeScreen extends StatefulWidget {
  const ReferenceHomeScreen({super.key});

  @override
  State<ReferenceHomeScreen> createState() => _ReferenceHomeScreenState();
}

enum _HomeProductView { grid, list, compact }

class _ReferenceHomeScreenState extends State<ReferenceHomeScreen> {
  Coupon? _coupon;
  bool _requestedCoupon = false;
  _HomeProductView _bestSellerView = _HomeProductView.grid;
  _HomeProductView _allProductsView = _HomeProductView.grid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedCoupon) {
      _requestedCoupon = true;
      _loadCoupon();
    }
  }

  Future<void> _loadCoupon() async {
    try {
      final items =
          await CouponRepository(AppScope.of(context).client).getCoupons();
      if (!mounted || items.isEmpty) return;
      setState(() => _coupon = items.first);
    } catch (_) {
      // Keep the isolated coupon fallback only when the server has no coupon.
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final products = _visualReferenceMode
        ? ReferenceDemoData.products
        : (app.products.isEmpty ? ReferenceDemoData.products : app.products);
    final auctions = _visualReferenceMode
        ? ReferenceDemoData.auctions
        : (app.auctions.isEmpty ? ReferenceDemoData.auctions : app.auctions);

    final featured =
        products.where((item) => (item.discount ?? 0) > 0).toList();
    final offers = featured.isEmpty ? products : featured;
    final bestSellers = products.toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));
    final coupon = _coupon ?? Coupon.referenceWelcome();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          key: const ValueKey('home-main-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: _TopBar(
                location: _visualReferenceMode ? 'الرياض' : app.location,
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 24),
              sliver: SliverList.list(
                children: [
                  _SearchBar(
                    onTap: () => Navigator.pushNamed(context, '/search'),
                  ),
                  const SizedBox(height: 13),
                  const _QuickEntries(),
                  const SizedBox(height: 14),
                  _LiveAuctions(auctions: auctions),
                  const SizedBox(height: 14),
                  _CouponSection(
                    coupon: coupon,
                    onAll: () => Navigator.pushNamed(context, '/coupon'),
                  ),
                  const SizedBox(height: 14),
                  _MiniProductSection(
                    title: 'العروض المميزة',
                    icon: Icons.sell_rounded,
                    products: offers,
                    showPrice: true,
                    onAll: () => Navigator.pushNamed(context, '/offers'),
                  ),
                  const SizedBox(height: 16),
                  _BestSellerSection(
                    products: bestSellers,
                    mode: _bestSellerView,
                    onModeChanged: (value) =>
                        setState(() => _bestSellerView = value),
                    onAll: () => Navigator.pushNamed(context, '/products'),
                  ),
                  const SizedBox(height: 17),
                  _AllProductsSection(
                    key: const ValueKey('home-all-products-section'),
                    products: products,
                    mode: _allProductsView,
                    onModeChanged: (value) =>
                        setState(() => _allProductsView = value),
                    onAll: () => Navigator.pushNamed(context, '/products'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 62,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 3, 14, 3),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Center(child: AppLogo(size: 49)),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/location'),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
                        const SizedBox(width: 2),
                        Text(
                          location.trim().isEmpty ? 'الرياض' : location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.forestDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.forestDark, size: 19),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                  icon: Badge(
                    backgroundColor: AppColors.terracotta,
                    label: const Text('3'),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 27,
                      color: AppColors.forestDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: const Color(0x1A0D4328),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            height: 54,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 14, 0),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              textDirection: TextDirection.ltr,
              children: [
                Icon(Icons.search_rounded, color: AppColors.muted, size: 25),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ابحث عن منتجات، حيوانات، مزادات وأكثر...',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _QuickEntries extends StatelessWidget {
  const _QuickEntries();

  @override
  Widget build(BuildContext context) {
    final entries = [
      _QuickEntry(
        label: 'المزادات',
        icon: Icons.gavel_rounded,
        background: AppColors.forestDark,
        foreground: Colors.white,
        route: '/auctions',
      ),
      _QuickEntry(
        label: 'التسوق',
        icon: Icons.shopping_cart_checkout_rounded,
        background: AppColors.terracotta,
        foreground: Colors.white,
        route: '/products',
      ),
      _QuickEntry(
        label: 'حيوانات',
        icon: Icons.pets_rounded,
        background: AppColors.surface,
        foreground: AppColors.forestDark,
        route: '/products',
        outlined: true,
      ),
      _QuickEntry(
        label: 'زراعة',
        icon: Icons.local_florist_rounded,
        background: AppColors.forest,
        foreground: Colors.white,
        route: '/categories',
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _QuickEntryTile(entry: entries[i])),
        ],
      ],
    );
  }
}

class _QuickEntry {
  const _QuickEntry({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.route,
    this.outlined = false,
  });
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String route;
  final bool outlined;
}

class _QuickEntryTile extends StatelessWidget {
  const _QuickEntryTile({required this.entry});
  final _QuickEntry entry;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.pushNamed(context, entry.route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.17,
              child: Container(
                decoration: BoxDecoration(
                  color: entry.background,
                  borderRadius: BorderRadius.circular(16),
                  border: entry.outlined ? Border.all(color: AppColors.border) : null,
                  boxShadow: entry.outlined
                      ? null
                      : const [
                          BoxShadow(
                            color: Color(0x100D4328),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                ),
                child: Icon(entry.icon, color: entry.foreground, size: 34),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.label,
              style: const TextStyle(
                color: AppColors.forestDark,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
}

class _LiveAuctions extends StatelessWidget {
  const _LiveAuctions({required this.auctions});
  final List<Auction> auctions;

  @override
  Widget build(BuildContext context) {
    final visible = auctions.take(3).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0DC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_rounded, color: AppColors.forestDark, size: 23),
              const SizedBox(width: 6),
              const Text(
                'المزادات الحية',
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/auctions'),
                child: const Text('عرض الكل ←'),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Colors.red),
                    SizedBox(width: 4),
                    Text('بث مباشر', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Expanded(child: _AuctionMiniCard(auction: visible[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AuctionMiniCard extends StatelessWidget {
  const _AuctionMiniCard({required this.auction});
  final Auction auction;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ConnectedAuctionDetailsScreen(auction: auction)),
        ),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.28,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppDataImage(auction.image, fit: BoxFit.cover),
                    const PositionedDirectional(
                      top: 5,
                      end: 5,
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.favorite_border_rounded,
                            size: 14, color: AppColors.terracotta),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 6, 7, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      auction.category.isEmpty ? 'مزاد مباشر' : auction.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 11, color: AppColors.terracotta),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            _duration(auction.remaining),
                            maxLines: 1,
                            style: const TextStyle(
                              color: AppColors.terracotta,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                color: AppColors.forestDark,
                alignment: Alignment.center,
                child: const Text(
                  'المزايدة الآن  ⚒',
                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CouponStrip extends StatelessWidget {
  const _CouponStrip({required this.coupon, this.onAll});
  final Coupon coupon;
  final VoidCallback? onAll;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ConnectedCouponsScreen(couponId: coupon.id)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [AppColors.terracotta, AppColors.forest, AppColors.forestDark],
              stops: [0, .30, 1],
            ),
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              const SizedBox(width: 10),
              SizedBox(
                width: 94,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.terracotta,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              coupon.code,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.terracotta,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onAll != null)
                      InkWell(
                        key: const ValueKey('home-coupons-view-all'),
                        onTap: onAll,
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(5, 3, 5, 1),
                          child: Text(
                            'عرض الكل ←',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('كوبون خصم خاص لك',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text('احصل على خصم ${coupon.discountLabel} على جميع المنتجات',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.local_activity_rounded, color: Colors.white, size: 37),
              const SizedBox(width: 15),
            ],
          ),
        ),
      );
}

class _CouponSection extends StatelessWidget {
  const _CouponSection({required this.coupon, required this.onAll});

  final Coupon coupon;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) =>
      _CouponStrip(coupon: coupon, onAll: onAll);
}

class _MiniProductSection extends StatelessWidget {
  const _MiniProductSection({
    required this.title,
    required this.icon,
    required this.products,
    required this.showPrice,
    required this.onAll,
    this.compact = false,
  });

  final String title;
  final IconData icon;
  final List<Product> products;
  final bool showPrice;
  final bool compact;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final visible = products.take(compact ? 4 : 3).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.forestDark),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.forestDark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            TextButton(onPressed: onAll, child: const Text('عرض الكل ←')),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(width: 7),
              Expanded(
                child: _ProductMiniCard(
                  product: visible[i],
                  showPrice: showPrice,
                  compact: compact,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ProductMiniCard extends StatelessWidget {
  const _ProductMiniCard({
    required this.product,
    required this.showPrice,
    required this.compact,
  });

  final Product product;
  final bool showPrice;
  final bool compact;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _openProduct(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B0D4328),
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: compact ? 1.45 : 1.38,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppDataImage(product.image, fit: BoxFit.cover),
                    if ((product.discount ?? 0) > 0)
                      PositionedDirectional(
                        top: 5,
                        end: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'خصم ${product.discount}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!compact || showPrice)
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (showPrice) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                formatPrice(product.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.forest,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (product.oldPrice != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  formatPrice(product.oldPrice!),
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 8,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
}

class _BestSellerSection extends StatelessWidget {
  const _BestSellerSection({
    required this.products,
    required this.mode,
    required this.onModeChanged,
    required this.onAll,
  });

  final List<Product> products;
  final _HomeProductView mode;
  final ValueChanged<_HomeProductView> onModeChanged;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final visible = products.take(4).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProductSectionHeader(
          title: 'الأكثر مبيعًا',
          icon: Icons.workspace_premium_outlined,
          prefix: 'home-best-sellers',
          mode: mode,
          onModeChanged: onModeChanged,
          onAll: onAll,
        ),
        const SizedBox(height: 7),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: switch (mode) {
            _HomeProductView.grid => _BestSellerGrid(
                key: const ValueKey('best-seller-grid'),
                products: visible,
              ),
            _HomeProductView.list => _ProductListLayout(
                key: const ValueKey('best-seller-list'),
                products: visible,
                dense: true,
              ),
            _HomeProductView.compact => _CompactProductGrid(
                key: const ValueKey('best-seller-compact'),
                products: visible,
                columns: 2,
              ),
          },
        ),
      ],
    );
  }
}

class _AllProductsSection extends StatelessWidget {
  const _AllProductsSection({
    super.key,
    required this.products,
    required this.mode,
    required this.onModeChanged,
    required this.onAll,
  });

  final List<Product> products;
  final _HomeProductView mode;
  final ValueChanged<_HomeProductView> onModeChanged;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProductSectionHeader(
          title: 'جميع المنتجات',
          icon: Icons.grid_view_rounded,
          prefix: 'home-all-products',
          mode: mode,
          onModeChanged: onModeChanged,
          onAll: onAll,
        ),
        const SizedBox(height: 8),
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                'لا توجد منتجات متاحة حاليًا',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          )
        else
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: switch (mode) {
              _HomeProductView.grid => _DetailedProductGrid(
                  key: const ValueKey('home-all-grid-layout'),
                  products: products,
                ),
              _HomeProductView.list => _ProductListLayout(
                  key: const ValueKey('home-all-list-layout'),
                  products: products,
                ),
              _HomeProductView.compact => _CompactProductGrid(
                  key: const ValueKey('home-all-compact-layout'),
                  products: products,
                  columns: 3,
                ),
            },
          ),
      ],
    );
  }
}

class _ProductSectionHeader extends StatelessWidget {
  const _ProductSectionHeader({
    required this.title,
    required this.icon,
    required this.prefix,
    required this.mode,
    required this.onModeChanged,
    required this.onAll,
  });

  final String title;
  final IconData icon;
  final String prefix;
  final _HomeProductView mode;
  final ValueChanged<_HomeProductView> onModeChanged;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.forestDark, size: 22),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.forestDark,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          _HomeViewToggle(
            prefix: prefix,
            selected: mode,
            onChanged: onModeChanged,
          ),
          const SizedBox(width: 5),
          TextButton(
            key: ValueKey('$prefix-view-all'),
            onPressed: onAll,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: const Text('عرض الكل ←'),
          ),
        ],
      );
}

class _HomeViewToggle extends StatelessWidget {
  const _HomeViewToggle({
    required this.prefix,
    required this.selected,
    required this.onChanged,
  });

  final String prefix;
  final _HomeProductView selected;
  final ValueChanged<_HomeProductView> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5EB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HomeViewButton(
              key: ValueKey('$prefix-view-grid'),
              icon: Icons.grid_view_rounded,
              selected: selected == _HomeProductView.grid,
              onTap: () => onChanged(_HomeProductView.grid),
            ),
            _HomeViewButton(
              key: ValueKey('$prefix-view-list'),
              icon: Icons.format_list_bulleted_rounded,
              selected: selected == _HomeProductView.list,
              onTap: () => onChanged(_HomeProductView.list),
            ),
            _HomeViewButton(
              key: ValueKey('$prefix-view-compact'),
              icon: Icons.view_agenda_outlined,
              selected: selected == _HomeProductView.compact,
              onTap: () => onChanged(_HomeProductView.compact),
            ),
          ],
        ),
      );
}

class _HomeViewButton extends StatelessWidget {
  const _HomeViewButton({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 29,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.forestDark : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : AppColors.muted,
          ),
        ),
      );
}

class _BestSellerGrid extends StatelessWidget {
  const _BestSellerGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) const SizedBox(width: 7),
            Expanded(child: _ImageOnlyProductCard(product: products[i])),
          ],
        ],
      );
}

class _ImageOnlyProductCard extends StatelessWidget {
  const _ImageOnlyProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final favorite = app.isFavorite(product.id);
    return InkWell(
      onTap: () => _openProduct(context, product),
      borderRadius: BorderRadius.circular(11),
      child: AspectRatio(
        aspectRatio: 1.18,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppDataImage(product.image, fit: BoxFit.cover),
              PositionedDirectional(
                top: 5,
                end: 5,
                child: InkWell(
                  onTap: () => app.toggleFavorite(product.id),
                  borderRadius: BorderRadius.circular(15),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.white,
                    child: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 14,
                      color: AppColors.terracotta,
                    ),
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

class _DetailedProductGrid extends StatelessWidget {
  const _DetailedProductGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          childAspectRatio: .79,
        ),
        itemBuilder: (context, index) =>
            _DetailedProductCard(product: products[index]),
      );
}

class _DetailedProductCard extends StatelessWidget {
  const _DetailedProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final favorite = app.isFavorite(product.id);
    return InkWell(
      onTap: () => _openProduct(context, product),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C0D4328),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppDataImage(product.image, fit: BoxFit.cover),
                  if ((product.discount ?? 0) > 0)
                    PositionedDirectional(
                      top: 7,
                      start: 7,
                      child: _DiscountBadge(value: product.discount!),
                    ),
                  PositionedDirectional(
                    top: 7,
                    end: 7,
                    child: _FavoriteCircle(
                      favorite: favorite,
                      onTap: () => app.toggleFavorite(product.id),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(9, 8, 9, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _ProductPriceRow(product: product),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 9.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        product.inStock ? 'متوفر' : 'غير متوفر',
                        style: TextStyle(
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.error,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductListLayout extends StatelessWidget {
  const _ProductListLayout({
    super.key,
    required this.products,
    this.dense = false,
  });

  final List<Product> products;
  final bool dense;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ProductListCard(product: products[i], dense: dense),
          ],
        ],
      );
}

class _ProductListCard extends StatelessWidget {
  const _ProductListCard({required this.product, required this.dense});

  final Product product;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final favorite = app.isFavorite(product.id);
    return InkWell(
      onTap: () => _openProduct(context, product),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: dense ? 94 : 112,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: dense ? 96 : 116,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppDataImage(product.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _ProductPriceRow(product: product),
                ],
              ),
            ),
            IconButton(
              onPressed: () => app.toggleFavorite(product.id),
              icon: Icon(
                favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: AppColors.terracotta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactProductGrid extends StatelessWidget {
  const _CompactProductGrid({
    super.key,
    required this.products,
    required this.columns,
  });

  final List<Product> products;
  final int columns;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          childAspectRatio: .88,
        ),
        itemBuilder: (context, index) =>
            _CompactProductCard(product: products[index]),
      );
}

class _CompactProductCard extends StatelessWidget {
  const _CompactProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _openProduct(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppDataImage(product.image, fit: BoxFit.cover),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.forest,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ProductPriceRow extends StatelessWidget {
  const _ProductPriceRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Flexible(
            child: Text(
              formatPrice(product.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.forest,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (product.oldPrice != null) ...[
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                formatPrice(product.oldPrice!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 9,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          ],
        ],
      );
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          'خصم $value%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _FavoriteCircle extends StatelessWidget {
  const _FavoriteCircle({required this.favorite, required this.onTap});

  final bool favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white,
          child: Icon(
            favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: AppColors.terracotta,
            size: 18,
          ),
        ),
      );
}

void _openProduct(BuildContext context, Product product) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UnifiedProductDetailsScreen(product: product),
    ),
  );
}

String _duration(Duration duration) {
  final total = duration.inSeconds.clamp(0, 359999);
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(h)}:${two(m)}:${two(s)}';
}
