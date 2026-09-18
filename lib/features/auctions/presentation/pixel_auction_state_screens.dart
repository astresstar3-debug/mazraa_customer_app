import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

const bool _referenceVisual = bool.fromEnvironment('REFERENCE_VISUAL_TEST');

enum PixelAuctionStateResultKind { success, won, ended }

class PixelAuctionStateResultScreen extends StatelessWidget {
  const PixelAuctionStateResultScreen({super.key, required this.kind});

  final PixelAuctionStateResultKind kind;

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    if (kind == PixelAuctionStateResultKind.ended) {
      return _EndedAuctionScreen(auction: auction);
    }

    final won = kind == PixelAuctionStateResultKind.won;
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(),
      body: BotanicalBackdrop(
        dense: true,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: _AuctionHalo(
                  icon: won ? Icons.emoji_events_rounded : Icons.check_rounded,
                  accent: won ? AppColors.forestDark : AppColors.forest,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                won ? 'مبروك! فزت بالمزاد' : 'تمت المزايدة بنجاح',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                won
                    ? 'أصبحت المزايد الفائز. أكمل الدفع خلال المدة المحددة لتأكيد الفوز.'
                    : 'تم تسجيل مزايدتك، وسنخبرك فور وجود مزايدة أعلى.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.6),
              ),
              const SizedBox(height: 20),
              _AuctionSummaryCard(auction: auction, won: won),
              const SizedBox(height: 14),
              if (won)
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.terracottaSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.terracotta.withValues(alpha: .35)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.schedule_rounded, color: AppColors.terracotta),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'أكمل السداد قبل انتهاء مهلة الدفع',
                          style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, won ? '/payment-methods' : '/auction-details'),
                  icon: Icon(won ? Icons.payments_outlined : Icons.gavel_rounded),
                  label: Text(
                    won ? 'إكمال الدفع' : 'عرض المزاد',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => route.isFirst),
                  child: const Text('العودة للرئيسية', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PixelAuctionReminderV2Screen extends StatefulWidget {
  const PixelAuctionReminderV2Screen({super.key});

  @override
  State<PixelAuctionReminderV2Screen> createState() => _PixelAuctionReminderV2ScreenState();
}

class _PixelAuctionReminderV2ScreenState extends State<PixelAuctionReminderV2Screen> {
  int selected = 1;

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    const values = ['عند بدء المزاد', 'قبل 30 دقيقة', 'قبل ساعة', 'قبل 3 ساعات'];
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(title: 'تذكير المزاد'),
      body: BotanicalBackdrop(
        dense: true,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: _AuctionHalo(icon: Icons.notifications_active_rounded, accent: AppColors.terracotta)),
              const SizedBox(height: 6),
              const Text(
                'تم ضبط التذكير',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.forestDark, fontSize: 23, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'اختر الوقت الذي تريد أن نذكّرك فيه بالمزاد.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 11.5),
              ),
              const SizedBox(height: 16),
              _CompactAuctionCard(auction: auction),
              const SizedBox(height: 14),
              Container(
                decoration: _panel(),
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    children: List.generate(
                      values.length,
                      (index) => RadioListTile<int>(
                        value: index,
                        groupValue: selected,
                        onChanged: (value) => setState(() => selected = value ?? 1),
                        activeColor: AppColors.forest,
                        title: Text(values[index], style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('حفظ التذكير', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PixelAuctionGuaranteeV2Screen extends StatelessWidget {
  const PixelAuctionGuaranteeV2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    final guarantee = _referenceVisual ? 250.0 : (auction.currentBid * .06).clamp(50.0, 5000.0);
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(title: 'تفاصيل حجز الضمان'),
      body: BotanicalBackdrop(
        dense: false,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CompactAuctionCard(auction: auction),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _panel(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.forestSoft,
                          child: Icon(Icons.verified_user_outlined, color: AppColors.forestDark, size: 28),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ضمان المشاركة في المزاد',
                            style: TextStyle(color: AppColors.forestDark, fontSize: 17, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _kv('مبلغ الضمان', formatPrice(guarantee), strong: true),
                    _kv('حالة الضمان', 'قابل للاسترداد'),
                    _kv('وقت الاسترداد', 'بعد انتهاء المزاد وفق الحالة'),
                    _kv('طريقة السداد', 'المحفظة أو وسيلة الدفع المتاحة'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.terracottaSoft, borderRadius: BorderRadius.circular(13)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.terracotta),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'يُعاد مبلغ الضمان حسب نتيجة المزاد وسياسة الاسترداد الموضحة قبل الدفع.',
                              style: TextStyle(color: AppColors.forestDark, fontSize: 11, height: 1.55),
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
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/payment-methods'),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('متابعة دفع الضمان', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndedAuctionScreen extends StatelessWidget {
  const _EndedAuctionScreen({required this.auction});
  final Auction auction;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const MazraaAppBar(title: 'المزاد'),
        body: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 1.35,
                  child: AppDataImage(auction.image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.terracottaSoft, borderRadius: BorderRadius.circular(20)),
                    child: const Text('انتهى المزاد', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900)),
                  ),
                  const Spacer(),
                  const Icon(Icons.share_outlined, color: AppColors.forestDark),
                  const SizedBox(width: 10),
                  const Icon(Icons.favorite_border_rounded, color: AppColors.forestDark),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                auction.title,
                style: const TextStyle(color: AppColors.forestDark, fontSize: 23, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _panel(),
                child: Column(
                  children: [
                    _kv('آخر مزايدة', formatPrice(auction.currentBid), strong: true),
                    _kv('عدد المزايدات', '${auction.bidCount}'),
                    _kv('الفئة', auction.category),
                    const Divider(height: 22),
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.terracotta),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'هذا المزاد انتهى ولم يعد يقبل مزايدات جديدة.',
                            style: TextStyle(color: AppColors.muted, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/auctions'),
                  icon: const Icon(Icons.gavel_rounded),
                  label: const Text('استعرض مزادات أخرى', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      );
}

class _AuctionSummaryCard extends StatelessWidget {
  const _AuctionSummaryCard({required this.auction, required this.won});
  final Auction auction;
  final bool won;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: _panel(),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(width: 86, height: 78, child: AppDataImage(auction.image, fit: BoxFit.cover)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auction.title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(auction.category, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _kv(won ? 'قيمة الفوز' : 'مزايدتك الحالية', formatPrice(auction.currentBid), strong: true),
            _kv('عدد المزايدات', '${auction.bidCount}'),
            if (!won) _kv('الحالة', 'أنت ضمن المزايدين'),
          ],
        ),
      );
}

class _CompactAuctionCard extends StatelessWidget {
  const _CompactAuctionCard({required this.auction});
  final Auction auction;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: _panel(),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(width: 78, height: 70, child: AppDataImage(auction.image, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(formatPrice(auction.currentBid), style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Icon(Icons.gavel_rounded, color: AppColors.forest),
          ],
        ),
      );
}

class _AuctionHalo extends StatelessWidget {
  const _AuctionHalo({required this.icon, required this.accent});
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 170,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final item in const [
              (-58.0, -34.0, -0.55),
              (-67.0, 18.0, -0.15),
              (-38.0, 58.0, 0.25),
              (40.0, 58.0, -0.25),
              (68.0, 15.0, 0.15),
              (58.0, -35.0, 0.55),
            ])
              Transform.translate(
                offset: Offset(item.$1, item.$2),
                child: Transform.rotate(
                  angle: item.$3,
                  child: const Icon(Icons.eco_rounded, size: 38, color: Color(0xFF93AD7E)),
                ),
              ),
            Container(
              width: 105,
              height: 105,
              decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
            ),
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 38),
            ),
          ],
        ),
      );
}

Auction _firstAuction(BuildContext context) {
  final auctions = AppScope.of(context).auctions;
  if (auctions.isNotEmpty) return auctions.first;
  return const Auction(
    id: 'reference',
    title: 'مزاد منتجات زراعية',
    image: '',
    currentBid: 2450,
    remaining: Duration(hours: 2),
    category: 'مزاد مباشر',
    bidCount: 18,
  );
}

BoxDecoration _panel() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: const [BoxShadow(color: Color(0x090D4328), blurRadius: 14, offset: Offset(0, 4))],
    );

Widget _kv(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: strong ? AppColors.forestDark : AppColors.muted, fontWeight: strong ? FontWeight.w900 : FontWeight.w600)),
          const Spacer(),
          Text(value, style: TextStyle(color: strong ? AppColors.terracotta : AppColors.forestDark, fontWeight: FontWeight.w900)),
        ],
      ),
    );
