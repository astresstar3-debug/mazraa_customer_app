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
import '../../marketplace/presentation/connected_marketplace_screens.dart';

const bool _visualReferenceMode =
    bool.fromEnvironment('REFERENCE_VISUAL_TEST', defaultValue: false);

class ReferenceHomeScreen extends StatefulWidget {
  const ReferenceHomeScreen({super.key});

  @override
  State<ReferenceHomeScreen> createState() => _ReferenceHomeScreenState();
}

class _ReferenceHomeScreenState extends State<ReferenceHomeScreen> {
  Coupon? _coupon;
  bool _requestedCoupon = false;

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
      final items = await CouponRepository(AppScope.of(context).client).getCoupons();
      if (!mounted || items.isEmpty) return;
      setState(() => _coupon = items.first);
    } catch (_) {
      // CouponRepository already supplies the isolated reference fallback.
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
    final featured = products.where((item) => (item.discount ?? 0) > 0).toList();
    final offers = featured.isEmpty ? products : featured;
    final coupon = _coupon ?? Coupon.referenceWelcome();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopBar(location: _visualReferenceMode ? 'الرياض' : app.location)),
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 18),
              sliver: SliverList.list(
                children: [
                  _SearchBar(onTap: () => Navigator.pushNamed(context, '/search')),
                  const SizedBox(height: 13),
                  const _QuickEntries(),
                  const SizedBox(height: 14),
                  _LiveAuctions(auctions: auctions),
                  const SizedBox(height: 14),
                  _CouponStrip(coupon: coupon),
                  const SizedBox(height: 14),
                  _MiniProductSection(
                    title: 'العروض المميزة',
                    icon: Icons.sell_rounded,
                    products: offers,
                    showPrice: true,
                    onAll: () => Navigator.pushNamed(context, '/offers'),
                  ),
                  const SizedBox(height: 13),
                  _MiniProductSection(
                    title: 'الأكثر مبيعًا',
                    icon: Icons.workspace_premium_rounded,
                    products: products,
                    showPrice: false,
                    compact: true,
                    onAll: () => Navigator.pushNamed(context, '/products'),
                  ),
                  const SizedBox(height: 12),
                  _AllProductsHeader(onAll: () => Navigator.pushNamed(context, '/products')),
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
                alignment: AlignmentDirectional.centerStart,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/location'),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
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
                alignment: AlignmentDirectional.centerEnd,
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
              children: [
                Icon(Icons.search_rounded, color: AppColors.muted, size: 25),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ابحث عن منتجات، حيوانات، مزادات وأكثر...',
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
  const _CouponStrip({required this.coupon});
  final Coupon coupon;

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
            children: [
              const SizedBox(width: 13),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.copy_rounded, size: 14, color: AppColors.terracotta),
                    const SizedBox(width: 5),
                    Text(coupon.code,
                        style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.forestDark),
            const SizedBox(width: 5),
            Text(title,
                style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
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
              Expanded(child: _ProductMiniCard(product: visible[i], showPrice: showPrice, compact: compact)),
            ],
          ],
        ),
      ],
    );
  }
}

class _ProductMiniCard extends StatelessWidget {
  const _ProductMiniCard({required this.product, required this.showPrice, required this.compact});
  final Product product;
  final bool showPrice;
  final bool compact;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ConnectedProductDetailsScreen(product: product)),
        ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.forest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('خصم ${product.discount}%',
                              style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w800)),
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
                      Text(product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
                      if (showPrice) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(formatPrice(product.price),
                                style: const TextStyle(color: AppColors.forest, fontSize: 11, fontWeight: FontWeight.w900)),
                            if (product.oldPrice != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(formatPrice(product.oldPrice!),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 8,
                                      decoration: TextDecoration.lineThrough,
                                    )),
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

class _AllProductsHeader extends StatelessWidget {
  const _AllProductsHeader({required this.onAll});
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.grid_view_rounded, color: AppColors.forestDark, size: 20),
          const SizedBox(width: 6),
          const Text('جميع المنتجات',
              style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 16)),
          const Spacer(),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, icon: Icon(Icons.grid_view_rounded, size: 15)),
              ButtonSegment(value: 1, icon: Icon(Icons.view_list_rounded, size: 15)),
            ],
            selected: const {0},
            showSelectedIcon: false,
            onSelectionChanged: (_) => onAll(),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 4),
          TextButton(onPressed: onAll, child: const Text('عرض الكل ←')),
        ],
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
