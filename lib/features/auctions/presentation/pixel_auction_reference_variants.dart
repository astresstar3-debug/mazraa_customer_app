import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

const bool _referenceVisual = bool.fromEnvironment('REFERENCE_VISUAL_TEST');

enum PixelAuctionReferenceVariant { crop, equipment }

class PixelAuctionReferenceVariantScreen extends StatelessWidget {
  const PixelAuctionReferenceVariantScreen({
    super.key,
    required this.variant,
  });

  final PixelAuctionReferenceVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      PixelAuctionReferenceVariant.crop => const _CropAuctionDetails(),
      PixelAuctionReferenceVariant.equipment => const _EquipmentAuctionDetails(),
    };
  }
}

class PixelAuctionSettlementScreen extends StatefulWidget {
  const PixelAuctionSettlementScreen({super.key});

  @override
  State<PixelAuctionSettlementScreen> createState() =>
      _PixelAuctionSettlementScreenState();
}

class _PixelAuctionSettlementScreenState
    extends State<PixelAuctionSettlementScreen> {
  int paymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    final args = _routeArgs(context);

    final winningBid = _number(
      args,
      'winningBid',
      _referenceVisual ? 4250 : auction.currentBid,
    );
    final deposit = _number(args, 'deposit', _referenceVisual ? 250 : 0);
    final remaining = _number(
      args,
      'remainingAmount',
      _referenceVisual ? 4000 : (winningBid - deposit).clamp(0, double.infinity),
    );
    final shipping = _number(args, 'shippingFee', _referenceVisual ? 150 : 0);
    final total = _number(args, 'total', _referenceVisual ? 4150 : remaining + shipping);
    final walletBalance = _number(args, 'walletBalance', _referenceVisual ? 2600 : 0);
    final cardLast4 = _text(args, 'cardLast4', _referenceVisual ? '4821' : '—');

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(),
      body: BotanicalBackdrop(
        dense: true,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: AppLogo(size: 56),
              ),
              const SizedBox(height: 6),
              const Text(
                'سداد قيمة المزاد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: _panel(),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 118,
                        height: 102,
                        child: AppDataImage(auction.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auction.title,
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.forest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.gavel_rounded,
                                    color: Colors.white, size: 17),
                                SizedBox(width: 6),
                                Text(
                                  'تم الفوز بالمزاد',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: _panel(),
                child: Column(
                  children: [
                    _amountRow(
                      Icons.gavel_rounded,
                      'قيمة آخر مزايدة (الفائز)',
                      winningBid,
                    ),
                    _amountRow(
                      Icons.account_balance_wallet_outlined,
                      'المبلغ المدفوع (العربون)',
                      -deposit,
                      valueColor: AppColors.forest,
                    ),
                    const Divider(height: 20),
                    _amountRow(
                      Icons.monetization_on_outlined,
                      'المبلغ المتبقي',
                      remaining,
                      valueColor: AppColors.terracotta,
                    ),
                    _amountRow(
                      Icons.local_shipping_outlined,
                      'رسوم التوصيل',
                      shipping,
                      valueColor: AppColors.forest,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.forestSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.savings_outlined,
                              color: AppColors.forestDark),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'المبلغ الإجمالي',
                              style: TextStyle(
                                color: AppColors.forestDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            formatPrice(total),
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _panel(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            color: AppColors.forestDark),
                        SizedBox(width: 7),
                        Text(
                          'اختر طريقة السداد',
                          style: TextStyle(
                            color: AppColors.forestDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _paymentTile(
                      index: 0,
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'رصيد المحفظة',
                      subtitle: formatPrice(walletBalance),
                    ),
                    const SizedBox(height: 9),
                    _paymentTile(
                      index: 1,
                      icon: Icons.credit_card_rounded,
                      title: 'بطاقة بنكية',
                      subtitle: cardLast4 == '—' ? 'بطاقة محفوظة' : '****$cardLast4',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.forestSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.lock_rounded,
                          color: AppColors.forestDark),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جميع عمليات الدفع تتم بشكل آمن ومشفّر',
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'لا نخزن بيانات البطاقة الحساسة داخل التطبيق.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/payment-success',
                    arguments: {
                      'amount': formatPrice(total),
                      'paymentMethod': paymentMethod == 0
                          ? 'المحفظة الداخلية'
                          : 'بطاقة •••• $cardLast4',
                    },
                  ),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text(
                    'تأكيد السداد',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
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

  Widget _paymentTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = paymentMethod == index;
    return InkWell(
      onTap: () => setState(() => paymentMethod = index),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.forestSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.ivory,
              child: Icon(icon, color: AppColors.forestDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.forest,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.forest : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _CropAuctionDetails extends StatelessWidget {
  const _CropAuctionDetails();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const _ReferenceAuctionBar(title: ''),
        body: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(
                image: 'assets/images/home/dates.png',
                status: '● مباشر',
                chip: 'منتجات زراعية',
              ),
              const SizedBox(height: 14),
              const Text(
                'محصول تمر خلاص فاخر',
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'تمور فاخرة بجودة عالية من مزارع الأحساء',
                style: TextStyle(color: AppColors.muted, fontSize: 11.5),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(child: _SpecBox(Icons.verified_outlined, 'درجة الجودة', 'درجة أولى')),
                  SizedBox(width: 8),
                  Expanded(child: _SpecBox(Icons.calendar_month_outlined, 'موسم الحصاد', '2026')),
                  SizedBox(width: 8),
                  Expanded(child: _SpecBox(Icons.location_on_outlined, 'الموقع', 'الأحساء')),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(child: _SpecBox(Icons.eco_outlined, 'الفئة', 'منتجات زراعية')),
                  SizedBox(width: 8),
                  Expanded(child: _SpecBox(Icons.inventory_2_outlined, 'الكمية', '500 كجم')),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.forestSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('أعلى مزايدة حالية', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('8,500 ر.س', style: TextStyle(color: AppColors.terracotta, fontSize: 23, fontWeight: FontWeight.w900)),
                          SizedBox(height: 7),
                          Text('الحد الأدنى للزيادة  250 ر.س', style: TextStyle(color: AppColors.forestDark, fontSize: 10.5)),
                        ],
                      ),
                    ),
                    SizedBox(width: 14),
                    SizedBox(width: 1, height: 100, child: ColoredBox(color: AppColors.border)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Icon(Icons.timer_outlined, color: AppColors.forestDark), SizedBox(width: 6), Text('الوقت المتبقي', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900))]),
                          SizedBox(height: 10),
                          Directionality(textDirection: TextDirection.ltr, child: Text('02 : 14 : 36', style: TextStyle(color: AppColors.forestDark, fontSize: 23, fontWeight: FontWeight.w900))),
                          SizedBox(height: 4),
                          Text('ساعة     دقيقة     ثانية', style: TextStyle(color: AppColors.muted, fontSize: 8.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: _panel(),
                child: const Row(
                  children: [
                    Icon(Icons.people_outline_rounded, color: AppColors.forestDark, size: 32),
                    SizedBox(width: 9),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('عدد المشاركين', style: TextStyle(color: AppColors.muted, fontSize: 10)), Text('12', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900))]),
                    Spacer(),
                    CircleAvatar(radius: 17, backgroundColor: AppColors.forestSoft, child: Icon(Icons.person_outline_rounded, size: 18)),
                    SizedBox(width: 3),
                    CircleAvatar(radius: 17, backgroundColor: AppColors.terracottaSoft, child: Icon(Icons.person_outline_rounded, size: 18)),
                    SizedBox(width: 3),
                    CircleAvatar(radius: 17, backgroundColor: AppColors.forestSoft, child: Icon(Icons.person_outline_rounded, size: 18)),
                    SizedBox(width: 6),
                    Text('+7', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _panel(),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: AppColors.forestSoft, child: Icon(Icons.local_shipping_outlined, color: AppColors.forestDark, size: 30)),
                    SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('التسليم أو الاستلام', style: TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(height: 5),
                          Text('التسليم متاح إلى مناطق الخدمة أو الاستلام من مزرعة البائع.', style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.55)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _bidButtons(context),
            ],
          ),
        ),
      );
}

class _EquipmentAuctionDetails extends StatelessWidget {
  const _EquipmentAuctionDetails();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const _ReferenceAuctionBar(title: 'تفاصيل المزاد'),
        bottomNavigationBar: const _BottomAuctionNav(),
        body: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.18,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const AppDataImage('assets/images/home/date_seedlings.png', fit: BoxFit.cover),
                      PositionedDirectional(
                        top: 12,
                        start: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(12)),
                          child: const Text('● مزاد مباشر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 12,
                        start: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(color: AppColors.forestDark.withValues(alpha: .88), borderRadius: BorderRadius.circular(12)),
                          child: const Row(children: [Icon(Icons.people_rounded, color: Colors.white, size: 18), SizedBox(width: 5), Text('12 مشارك', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 12,
                        end: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.forestDark.withValues(alpha: .90), borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            children: [
                              Directionality(textDirection: TextDirection.ltr, child: Text('00:18:56', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))),
                              Text('ساعة   دقيقة   ثانية', style: TextStyle(color: Colors.white70, fontSize: 8)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _panel(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Expanded(child: Text('جرار زراعي صغير', style: TextStyle(color: AppColors.forestDark, fontSize: 23, fontWeight: FontWeight.w900))),
                        Text('John Deere', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: _SpecBox(Icons.agriculture_outlined, 'القسم', 'معدات زراعية')),
                        SizedBox(width: 8),
                        Expanded(child: _SpecBox(Icons.calendar_month_outlined, 'الموديل', '2022')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Expanded(child: _SpecBox(Icons.schedule_outlined, 'ساعات التشغيل', '1,240')),
                        SizedBox(width: 7),
                        Expanded(child: _SpecBox(Icons.build_outlined, 'الحالة', 'مستعمل ممتاز')),
                        SizedBox(width: 7),
                        Expanded(child: _SpecBox(Icons.location_on_outlined, 'الموقع', 'القصيم')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(18)),
                child: const Row(
                  children: [
                    Icon(Icons.campaign_outlined, color: AppColors.forestDark),
                    SizedBox(width: 8),
                    Expanded(child: Text('أعلى مزايدة حالياً', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900))),
                    Text('28,500 ر.س', style: TextStyle(color: AppColors.forestDark, fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _infoPanel(Icons.remove_red_eye_outlined, 'معاينة المعدات', 'من الأحد إلى الخميس\n9:00 ص - 4:00 م\nموقع المزرعة - القصيم')),
                  const SizedBox(width: 9),
                  Expanded(child: _infoPanel(Icons.local_shipping_outlined, 'الاستلام', 'خلال 7 أيام من الفوز\nمن موقع المزرعة\nالقصيم')),
                ],
              ),
              const SizedBox(height: 18),
              _bidButtons(context),
            ],
          ),
        ),
      );
}

Widget _hero({required String image, required String status, required String chip}) =>
    AspectRatio(
      aspectRatio: 1.45,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppDataImage(image, fit: BoxFit.cover),
            PositionedDirectional(
              top: 12,
              start: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
            const PositionedDirectional(
              top: 12,
              end: 12,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.favorite_border_rounded, color: AppColors.terracotta),
              ),
            ),
            PositionedDirectional(
              bottom: 12,
              end: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(color: AppColors.ivory.withValues(alpha: .93), borderRadius: BorderRadius.circular(12)),
                child: Text(chip, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );

Widget _bidButtons(BuildContext context) => Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/auction-bid'),
              icon: const Icon(Icons.gavel_rounded),
              label: const Text('المزايدة الآن', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border_rounded),
              label: const Text('متابعة فقط', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ],
    );

class _ReferenceAuctionBar extends StatelessWidget implements PreferredSizeWidget {
  const _ReferenceAuctionBar({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark),
              ),
              if (title.isNotEmpty)
                Text(title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 17)),
              const Spacer(),
              const AppLogo(size: 50),
              const Spacer(),
              const SizedBox(width: 44),
            ],
          ),
        ),
      );
}

class _BottomAuctionNav extends StatelessWidget {
  const _BottomAuctionNav();
  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          height: 70,
          decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(Icons.home_outlined, 'الرئيسية', false),
              _NavItem(Icons.grid_view_rounded, 'المنتجات', false),
              _NavItem(Icons.gavel_rounded, 'المزادات', true),
              _NavItem(Icons.shopping_cart_outlined, 'سلة التسوق', false),
              _NavItem(Icons.person_outline_rounded, 'حسابي', false),
            ],
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.icon, this.label, this.active);
  final IconData icon;
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? AppColors.forest : AppColors.muted),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: active ? AppColors.forest : AppColors.muted, fontSize: 9, fontWeight: active ? FontWeight.w900 : FontWeight.w500)),
        ],
      );
}

class _SpecBox extends StatelessWidget {
  const _SpecBox(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.forestDark, size: 20),
            const SizedBox(height: 5),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 9.5)),
            const SizedBox(height: 3),
            Text(value, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 11.5, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

Widget _infoPanel(IconData icon, String title, String body) => Container(
      padding: const EdgeInsets.all(12),
      decoration: _panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.forestDark), const SizedBox(width: 6), Expanded(child: Text(title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)))]),
          const SizedBox(height: 7),
          Text(body, style: const TextStyle(color: AppColors.muted, fontSize: 9.5, height: 1.6)),
        ],
      ),
    );

Widget _amountRow(
  IconData icon,
  String label,
  num value, {
  Color? valueColor,
}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.forestDark, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.forestDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            formatPrice(value),
            style: TextStyle(
              color: valueColor ?? AppColors.forestDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );

Auction _firstAuction(BuildContext context) {
  final values = AppScope.of(context).auctions;
  if (values.isNotEmpty) return values.first;
  return const Auction(
    id: 'auction',
    title: 'خروف نعيمي أصيل',
    image: 'assets/images/home/najdi_sheep.png',
    currentBid: 4250,
    remaining: Duration(hours: 2),
    category: 'حيوانات',
    bidCount: 12,
  );
}

Map<String, dynamic> _routeArgs(BuildContext context) {
  final value = ModalRoute.of(context)?.settings.arguments;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, dynamic>{};
}

num _number(Map<String, dynamic> args, String key, num fallback) {
  final value = args[key];
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? fallback;
}

String _text(Map<String, dynamic> args, String key, String fallback) {
  final value = args[key]?.toString().trim();
  return value == null || value.isEmpty ? fallback : value;
}

BoxDecoration _panel() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x090D4328),
          blurRadius: 13,
          offset: Offset(0, 4),
        ),
      ],
    );
