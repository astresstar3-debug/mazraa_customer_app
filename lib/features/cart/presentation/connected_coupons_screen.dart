import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/coupon_repository.dart';
import '../domain/coupon.dart';

class ConnectedCouponsScreen extends StatefulWidget {
  const ConnectedCouponsScreen({super.key, this.couponId});

  final int? couponId;

  @override
  State<ConnectedCouponsScreen> createState() => _ConnectedCouponsScreenState();
}

class _ConnectedCouponsScreenState extends State<ConnectedCouponsScreen> {
  bool loading = true;
  String? error;
  List<Coupon> coupons = const [];
  Coupon? coupon;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }
    try {
      final repository = CouponRepository(AppScope.of(context).client);
      if (widget.couponId != null) {
        final loaded = await repository.getCoupon(widget.couponId!);
        if (!mounted) return;
        setState(() => coupon = loaded);
      } else {
        final loaded = await repository.getCoupons();
        if (!mounted) return;
        setState(() => coupons = loaded);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e is ApiException ? e.message : 'تعذر تحميل الكوبونات.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailMode = widget.couponId != null;
    return Scaffold(
      appBar: MazraaAppBar(
        title: detailMode ? null : 'الكوبونات',
        showLogo: true,
      ),
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 28),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: loading
              ? const _CouponLoading(key: ValueKey('loading'))
              : error != null
                  ? ResultStateView(
                      key: const ValueKey('error'),
                      kind: ResultKind.error,
                      title: 'تعذر تحميل الكوبونات',
                      message: error!,
                      primaryLabel: 'إعادة المحاولة',
                      onPrimary: _load,
                    )
                  : detailMode
                      ? _CouponDetails(
                          key: const ValueKey('detail'),
                          coupon: coupon,
                        )
                      : _CouponList(
                          key: const ValueKey('list'),
                          coupons: coupons,
                        ),
        ),
      ),
    );
  }
}

class _CouponLoading extends StatelessWidget {
  const _CouponLoading({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 52),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _CouponList extends StatelessWidget {
  const _CouponList({super.key, required this.coupons});

  final List<Coupon> coupons;

  @override
  Widget build(BuildContext context) {
    if (coupons.isEmpty) {
      return const ResultStateView(
        kind: ResultKind.empty,
        title: 'لا توجد كوبونات متاحة',
        message: 'ستظهر هنا الكوبونات النشطة فور توفرها من المتجر.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'كوبونات خاصة لك',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.forestDark,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          'اختر الكوبون لعرض تفاصيله وشروط استخدامه',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
        ),
        const SizedBox(height: 18),
        ...coupons.map(
          (coupon) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CouponListCard(coupon: coupon),
          ),
        ),
      ],
    );
  }
}

class _CouponListCard extends StatelessWidget {
  const _CouponListCard({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConnectedCouponsScreen(couponId: coupon.id),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 128,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .07),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  color: AppColors.forestDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        coupon.name.isEmpty ? 'كوبون خصم' : coupon.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          coupon.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.forestDark,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'صالح حتى ${coupon.validityLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  color: AppColors.terracotta,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'خصم',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        coupon.discountLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CouponDetails extends StatelessWidget {
  const _CouponDetails({super.key, required this.coupon});

  final Coupon? coupon;

  @override
  Widget build(BuildContext context) {
    final value = coupon;
    if (value == null) {
      return const ResultStateView(
        kind: ResultKind.empty,
        title: 'الكوبون غير متاح',
        message: 'لم يعد هذا الكوبون متاحًا حاليًا.',
      );
    }

    final terms = <String>[
      if (value.description.isNotEmpty) value.description,
      if (value.minimumOrderAmount > 0)
        'الحد الأدنى للاستفادة من الكوبون هو ${formatPrice(value.minimumOrderAmount)}.',
      if (value.maximumDiscountAmount > 0)
        'أقصى قيمة للخصم هي ${formatPrice(value.maximumDiscountAmount)}.',
      if (value.validTo != null) 'تنتهي صلاحية الكوبون في ${value.validityLabel}.',
      if (value.usageLimit > 0)
        'عدد الاستخدامات المتبقية ${value.usageLimit - value.usedCount < 0 ? 0 : value.usageLimit - value.usedCount}.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '🍂 كوبون خاص لك 🍂',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.forestDark,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 18),
        _CouponTicket(coupon: value),
        const SizedBox(height: 16),
        AppSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.calendar_month_rounded,
                title: 'صالح حتى',
                value: value.validityLabel,
              ),
              const Divider(height: 1),
              _InfoRow(
                icon: Icons.add_shopping_cart_rounded,
                title: 'الحد الأدنى للطلب',
                value: value.minimumOrderLabel,
              ),
              if (value.maximumDiscountAmount > 0) ...[
                const Divider(height: 1),
                _InfoRow(
                  icon: Icons.savings_outlined,
                  title: 'الحد الأعلى للخصم',
                  value: value.maximumDiscountLabel,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: value.code));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ كود الكوبون')),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('نسخ الكود'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/products'),
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text('تسوق الآن'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (terms.isNotEmpty)
          AppSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description_outlined, color: AppColors.forest),
                    SizedBox(width: 8),
                    Text(
                      'شروط الاستخدام',
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...terms.map(
                  (term) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.eco_rounded,
                            size: 15,
                            color: AppColors.terracotta,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(child: Text(term)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ConnectedCouponsScreen()),
          ),
          icon: const Icon(Icons.local_offer_outlined),
          label: const Text('عرض كل الكوبونات'),
        ),
      ],
    );
  }
}

class _CouponTicket extends StatelessWidget {
  const _CouponTicket({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) => Container(
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .09),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF0C4B2A), Color(0xFF17673B)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (coupon.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppDataImage(
                          coupon.imageUrl,
                          width: 72,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9ED),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.forest.withValues(alpha: .45),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        coupon.code,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.forestDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 23,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 1,
              child: CustomPaint(painter: _DashPainter()),
            ),
            Expanded(
              flex: 3,
              child: Container(
                height: double.infinity,
                color: AppColors.terracotta,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'خصم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        coupon.discountLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Icon(Icons.energy_savings_leaf_rounded,
                        color: Colors.white, size: 26),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: AppColors.forest, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.forestDark,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..strokeWidth = 2;
    const dash = 7.0;
    const gap = 7.0;
    for (double y = 5; y < size.height; y += dash + gap) {
      canvas.drawLine(Offset.zero.translate(0, y), Offset(0, y + dash), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
