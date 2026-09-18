import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

enum PixelAuctionResultKind { success, won, ended }

Auction _firstAuction(BuildContext context) {
  final live = AppScope.of(context).auctions;
  return live.isNotEmpty ? live.first : ReferenceDemoData.auctions.first;
}

class PixelAuctionListScreen extends StatefulWidget {
  const PixelAuctionListScreen({super.key});

  @override
  State<PixelAuctionListScreen> createState() => _PixelAuctionListScreenState();
}

class _PixelAuctionListScreenState extends State<PixelAuctionListScreen> {
  int state = 0;
  int category = 0;

  static const states = ['مباشر', 'قادم', 'منتهي'];
  static const categories = ['حيوانات', 'منتجات زراعية', 'معدات', 'تربية النحل'];

  @override
  Widget build(BuildContext context) {
    final server = AppScope.of(context).auctions;
    final auctions = server.isEmpty ? ReferenceDemoData.auctions : server;
    final cards = auctions.length >= 4
        ? auctions.take(4).toList()
        : [
            ...auctions,
            ...ReferenceDemoData.auctions,
          ].take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _AuctionHeader(title: 'المزادات'),
            Expanded(
              child: AppPage(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 2, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 47,
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search_rounded, color: AppColors.muted),
                                SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    'ابحث عن مزاد...',
                                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pushNamed(context, '/auction-filter'),
                            icon: const Icon(Icons.tune_rounded, color: AppColors.forestDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: List.generate(states.length, (index) {
                        final active = state == index;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(end: index == states.length - 1 ? 0 : 7),
                            child: InkWell(
                              onTap: () => setState(() => state = index),
                              borderRadius: BorderRadius.circular(13),
                              child: Container(
                                height: 49,
                                decoration: BoxDecoration(
                                  color: active ? AppColors.forest : AppColors.surface,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: active ? AppColors.forest : AppColors.border),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (index == 0) ...[
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: active ? Colors.white : AppColors.terracotta,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                    Text(
                                      states[index],
                                      style: TextStyle(
                                        color: active ? Colors.white : AppColors.forestDark,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 7),
                        itemBuilder: (context, index) => ChoiceChip(
                          label: Text(categories[index]),
                          selected: category == index,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => category = index),
                          selectedColor: const Color(0xFFE2E9D8),
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.border),
                          labelStyle: TextStyle(
                            color: AppColors.forestDark,
                            fontSize: 10,
                            fontWeight: category == index ? FontWeight.w900 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/auction-filter'),
                          icon: const Icon(Icons.tune_rounded, size: 17),
                          label: const Text('تصفية'),
                        ),
                        const SizedBox(width: 7),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.swap_vert_rounded, size: 17),
                          label: const Text('الأقرب انتهاءً'),
                        ),
                        const Spacer(),
                        Text(
                          '${cards.length} مزادات',
                          style: const TextStyle(color: AppColors.muted, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cards.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: .60,
                        crossAxisSpacing: 9,
                        mainAxisSpacing: 9,
                      ),
                      itemBuilder: (context, index) => _AuctionListCard(
                        auction: cards[index],
                        upcoming: state == 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _AuctionBottomNav(active: 2),
          ],
        ),
      ),
    );
  }
}

class _AuctionListCard extends StatelessWidget {
  const _AuctionListCard({required this.auction, required this.upcoming});

  final Auction auction;
  final bool upcoming;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.pushNamed(context, '/auction-details'),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppDataImage(auction.image, fit: BoxFit.cover),
                    PositionedDirectional(
                      top: 7,
                      end: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: upcoming ? AppColors.forest : AppColors.terracotta,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          upcoming ? 'قادم' : '● مباشر',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const PositionedDirectional(
                      top: 7,
                      start: 7,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.terracotta),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.forestDark, fontSize: 11.5, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: AppColors.muted),
                        Text(' الرياض', style: TextStyle(color: AppColors.muted, fontSize: 8.5)),
                        Spacer(),
                        Icon(Icons.people_outline_rounded, size: 12, color: AppColors.muted),
                        Text(' 24', style: TextStyle(color: AppColors.muted, fontSize: 8.5)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      upcoming ? 'السعر الابتدائي' : 'المزايدة حاليًا',
                      style: const TextStyle(color: AppColors.muted, fontSize: 8.5),
                    ),
                    Text(
                      formatPrice(auction.currentBid),
                      style: const TextStyle(color: AppColors.forest, fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.terracottaSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 12, color: AppColors.terracotta),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              upcoming ? 'يبدأ خلال ساعتين' : 'ينتهي خلال 02:14:16',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.terracotta, fontSize: 8.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: FilledButton.icon(
                        onPressed: () => upcoming
                            ? Navigator.pushNamed(context, '/auction-reminder')
                            : Navigator.pushNamed(context, '/auction-bid'),
                        icon: Icon(upcoming ? Icons.notifications_none_rounded : Icons.gavel_rounded, size: 15),
                        label: Text(upcoming ? 'ذكرني' : 'زاود الآن', style: const TextStyle(fontSize: 9.5)),
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

class PixelAuctionFilterScreen extends StatefulWidget {
  const PixelAuctionFilterScreen({super.key});

  @override
  State<PixelAuctionFilterScreen> createState() => _PixelAuctionFilterScreenState();
}

class _PixelAuctionFilterScreenState extends State<PixelAuctionFilterScreen> {
  RangeValues range = const RangeValues(500, 10000);
  int category = 0;
  int ending = 0;
  bool delivery = true;
  bool guaranteed = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const MazraaAppBar(title: 'تصفية المزادات'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('القسم', Icons.category_outlined),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['الكل', 'حيوانات', 'منتجات زراعية', 'معدات', 'أعلاف']
                    .asMap()
                    .entries
                    .map(
                      (entry) => ChoiceChip(
                        label: Text(entry.value),
                        selected: category == entry.key,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => category = entry.key),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              const _SectionTitle('نطاق السعر', Icons.payments_outlined),
              RangeSlider(
                values: range,
                min: 0,
                max: 30000,
                divisions: 60,
                onChanged: (value) => setState(() => range = value),
              ),
              Row(
                children: [
                  _PriceBox('${range.end.toInt()} ر.س'),
                  const Spacer(),
                  _PriceBox('${range.start.toInt()} ر.س'),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionTitle('وقت الانتهاء', Icons.schedule_outlined),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['الكل', 'خلال ساعة', 'اليوم', 'هذا الأسبوع']
                    .asMap()
                    .entries
                    .map(
                      (entry) => ChoiceChip(
                        label: Text(entry.value),
                        selected: ending == entry.key,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => ending = entry.key),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              _ToggleRow(
                icon: Icons.local_shipping_outlined,
                label: 'يتوفر توصيل',
                value: delivery,
                onChanged: (value) => setState(() => delivery = value),
              ),
              _ToggleRow(
                icon: Icons.verified_user_outlined,
                label: 'مزادات بضمان فقط',
                value: guaranteed,
                onChanged: (value) => setState(() => guaranteed = value),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('عرض النتائج', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('إعادة تعيين')),
            ],
          ),
        ),
      );
}

class PixelAuctionDetailsScreen extends StatelessWidget {
  const PixelAuctionDetailsScreen({super.key, this.galleryMode = false});

  final bool galleryMode;

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          bottom: false,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark),
                ),
                const Spacer(),
                const AppLogo(size: 45),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_outlined)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded)),
              ],
            ),
          ),
        ),
      ),
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 2, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: galleryMode ? 1.02 : 1.30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppDataImage(auction.image, fit: BoxFit.cover),
                    PositionedDirectional(
                      top: 10,
                      end: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('● مزاد مباشر', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 62,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(width: 7),
                itemBuilder: (context, index) => Container(
                  width: 80,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: index == 0 ? AppColors.forest : AppColors.border, width: index == 0 ? 2 : 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppDataImage(auction.image, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auction.title,
              style: const TextStyle(color: AppColors.forestDark, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: AppColors.muted),
                Text(' الرياض • مزرعة موثقة', style: TextStyle(color: AppColors.muted, fontSize: 10.5)),
                Spacer(),
                Icon(Icons.verified_rounded, color: AppColors.forest, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F0DC),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _Metric(label: 'السعر الحالي', value: '4,200 ر.س', icon: Icons.payments_outlined)),
                      SizedBox(width: 1, height: 44, child: ColoredBox(color: AppColors.border)),
                      Expanded(child: _Metric(label: 'المزايدات', value: '24', icon: Icons.people_outline_rounded)),
                      SizedBox(width: 1, height: 44, child: ColoredBox(color: AppColors.border)),
                      Expanded(child: _Metric(label: 'متبقي', value: '02:14:16', icon: Icons.schedule_rounded, color: AppColors.terracotta)),
                    ],
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: .63, minHeight: 5, borderRadius: BorderRadius.all(Radius.circular(5))),
                ],
              ),
            ),
            const SizedBox(height: 11),
            const _AuctionInfoRows(),
            const SizedBox(height: 13),
            const _SectionTitle('وصف المزاد', Icons.description_outlined),
            const SizedBox(height: 7),
            Text(
              auction.description.isEmpty
                  ? 'خروف نجدي أصيل بحالة ممتازة، تم فحصه وتوثيق معلومات المزاد والصور من البائع.'
                  : auction.description,
              style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.7),
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.forestSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.storefront_rounded, color: AppColors.forest),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مزرعة الخير', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                        Text('بائع موثق • 4.9 ★', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/guarantee-details'),
              icon: const Icon(Icons.shield_outlined),
              label: const Text('عرض تفاصيل الضمان'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/auction-bid'),
                icon: const Icon(Icons.gavel_rounded),
                label: const Text('قدم مزايدتك', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuctionInfoRows extends StatelessWidget {
  const _AuctionInfoRows();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            _InfoRow(Icons.info_outline_rounded, 'حالة المنتج', 'ممتازة'),
            Divider(height: 16),
            _InfoRow(Icons.category_outlined, 'القسم', 'حيوانات ومواشي'),
            Divider(height: 16),
            _InfoRow(Icons.local_shipping_outlined, 'التوصيل', 'متوفر داخل المملكة'),
            Divider(height: 16),
            _InfoRow(Icons.verified_user_outlined, 'الضمان', 'يتطلب حجز ضمان'),
          ],
        ),
      );
}

class PixelBidScreen extends StatefulWidget {
  const PixelBidScreen({super.key});

  @override
  State<PixelBidScreen> createState() => _PixelBidScreenState();
}

class _PixelBidScreenState extends State<PixelBidScreen> {
  int amount = 4500;
  bool accepted = true;

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(title: 'تقديم المزايدة'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuctionMini(auction: auction),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F0DC),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Text('المزايدة الحالية', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  SizedBox(height: 5),
                  Text('2,450 ر.س', style: TextStyle(color: AppColors.forestDark, fontSize: 28, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('الحد الأدنى للمزايدة التالية 2,500 ر.س', style: TextStyle(color: AppColors.terracotta, fontSize: 10, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text('حدد قيمة مزايدتك', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => amount = (amount - 50).clamp(2500, 999999)),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '$amount ر.س',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.forestDark, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => amount += 50),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                for (final value in [2500, 2750, 3000]) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () => setState(() => amount = value),
                        child: Text('$value'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.terracottaSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.terracotta),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'عند تأكيد المزايدة لا يمكن التراجع عنها. تأكد من القيمة قبل المتابعة.',
                      style: TextStyle(color: AppColors.forestDark, fontSize: 10, height: 1.55),
                    ),
                  ),
                ],
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: (value) => setState(() => accepted = value ?? false),
              title: const Text('أوافق على شروط وأحكام المزاد', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: accepted ? () => Navigator.pushNamed(context, '/auction-bid-confirm') : null,
                icon: const Icon(Icons.gavel_rounded),
                label: const Text('تأكيد المزايدة', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelBidConfirmScreen extends StatelessWidget {
  const PixelBidConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(title: 'تأكيد المزايدة'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuctionMini(auction: auction),
            const SizedBox(height: 14),
            const Center(
              child: CircleAvatar(
                radius: 43,
                backgroundColor: AppColors.forestSoft,
                child: Icon(Icons.gavel_rounded, color: AppColors.forestDark, size: 42),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'راجع تفاصيل مزايدتك',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.forestDark, fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            const _ReviewCard(),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/auction-success'),
                icon: const Icon(Icons.verified_rounded),
                label: const Text('تأكيد وإرسال المزايدة', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 7),
            OutlinedButton(onPressed: () => Navigator.maybePop(context), child: const Text('تعديل المزايدة')),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            _InfoRow(Icons.payments_outlined, 'قيمة المزايدة', '2,500 ر.س'),
            Divider(height: 17),
            _InfoRow(Icons.shield_outlined, 'حجز الضمان', '250 ر.س'),
            Divider(height: 17),
            _InfoRow(Icons.account_balance_wallet_outlined, 'الإجمالي المحجوز', '2,750 ر.س'),
          ],
        ),
      );
}

class PixelAuctionResultScreen extends StatelessWidget {
  const PixelAuctionResultScreen({super.key, required this.kind});

  final PixelAuctionResultKind kind;

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    final success = kind == PixelAuctionResultKind.success;
    final won = kind == PixelAuctionResultKind.won;
    final title = success ? 'تمت المزايدة بنجاح' : won ? 'مبروك! فزت بالمزاد' : 'انتهى المزاد';
    final message = success
        ? 'تم تسجيل مزايدتك وأصبحت أعلى مزايدة حاليًا.'
        : won
            ? 'تهانينا، مزايدتك هي الأعلى وتم إغلاق المزاد لصالحك.'
            : 'انتهى وقت المزاد ولم تعد المزايدات متاحة.';
    final icon = success ? Icons.check_circle_rounded : won ? Icons.emoji_events_rounded : Icons.eco_rounded;
    final tone = success || won ? AppColors.forest : AppColors.terracotta;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: tone, size: 58),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.forestDark, fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.55)),
            const SizedBox(height: 18),
            _AuctionMini(auction: auction),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoRow(Icons.gavel_rounded, won ? 'مزايدتك الفائزة' : 'مزايدتك', won ? '4,250 ر.س' : '4,500 ر.س'),
                  const Divider(height: 17),
                  _InfoRow(Icons.people_outline_rounded, 'عدد المزايدات', won ? '28' : '25'),
                  const Divider(height: 17),
                  _InfoRow(Icons.schedule_rounded, won ? 'انتهى المزاد' : 'الوقت المتبقي', won ? 'الآن' : '02:13:48'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/my-auctions', (route) => route.isFirst),
                child: Text(won ? 'إكمال عملية الشراء' : 'عرض مزاداتي', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 7),
            OutlinedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/auctions', (route) => route.isFirst),
              child: const Text('العودة للمزادات'),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelMyAuctionsScreen extends StatelessWidget {
  const PixelMyAuctionsScreen({super.key, this.history = false});

  final bool history;

  @override
  Widget build(BuildContext context) {
    final auctions = ReferenceDemoData.auctions.take(4).toList();
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: MazraaAppBar(title: history ? 'سجل المزايدات' : 'مزاداتي'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!history)
              const Row(
                children: [
                  Expanded(child: _StatCard('نشطة', '2', AppColors.forest)),
                  SizedBox(width: 7),
                  Expanded(child: _StatCard('فزت بها', '1', Color(0xFF6D8C55))),
                  SizedBox(width: 7),
                  Expanded(child: _StatCard('منتهية', '3', AppColors.terracotta)),
                ],
              ),
            if (!history) const SizedBox(height: 14),
            ...auctions.map(
              (auction) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: history ? _HistoryCard(auction: auction) : _MyAuctionCard(auction: auction),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _AuctionBottomNav(active: 2),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9.5)),
          ],
        ),
      );
}

class _MyAuctionCard extends StatelessWidget {
  const _MyAuctionCard({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(width: 92, height: 86, child: AppDataImage(auction.image, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('مزايدتك: 4,500 ر.س', style: TextStyle(color: AppColors.forest, fontSize: 11, fontWeight: FontWeight.w900)),
                  const Text('أنت صاحب أعلى مزايدة حاليًا', style: TextStyle(color: AppColors.success, fontSize: 9.5)),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(value: .6, minHeight: 4, borderRadius: BorderRadius.all(Radius.circular(4))),
                  const SizedBox(height: 4),
                  const Text('متبقي 02:13:48', style: TextStyle(color: AppColors.terracotta, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.forestSoft,
              child: const Icon(Icons.gavel_rounded, color: AppColors.forest),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('16 سبتمبر • 06:15 ص', style: TextStyle(color: AppColors.muted, fontSize: 9)),
                ],
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('4,500 ر.س', style: TextStyle(color: AppColors.forest, fontWeight: FontWeight.w900)),
                Text('أعلى مزايدة', style: TextStyle(color: AppColors.success, fontSize: 8.5)),
              ],
            ),
          ],
        ),
      );
}

class PixelReminderScreen extends StatefulWidget {
  const PixelReminderScreen({super.key});

  @override
  State<PixelReminderScreen> createState() => _PixelReminderScreenState();
}

class _PixelReminderScreenState extends State<PixelReminderScreen> {
  int choice = 1;

  @override
  Widget build(BuildContext context) {
    final auction = _firstAuction(context);
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(title: 'تذكير المزاد'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.forestSoft,
                child: Icon(Icons.notifications_active_rounded, size: 47, color: AppColors.forest),
              ),
            ),
            const SizedBox(height: 13),
            const Text('لن يفوتك المزاد', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('اختر متى تريد أن نذكرك قبل بداية المزاد', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 11)),
            const SizedBox(height: 16),
            _AuctionMini(auction: auction),
            const SizedBox(height: 12),
            ...['قبل ساعة', 'قبل 30 دقيقة', 'قبل 10 دقائق', 'عند بدء المزاد'].asMap().entries.map(
                  (entry) => RadioListTile<int>(
                    value: entry.key,
                    groupValue: choice,
                    onChanged: (value) => setState(() => choice = value ?? 0),
                    title: Text(entry.value),
                  ),
                ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.notifications_active_rounded),
                label: const Text('حفظ التذكير', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelGuaranteeScreen extends StatelessWidget {
  const PixelGuaranteeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const MazraaAppBar(title: 'تفاصيل حجز الضمان'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.forestSoft,
                  child: Icon(Icons.shield_rounded, size: 48, color: AppColors.forest),
                ),
              ),
              const SizedBox(height: 13),
              const Text('ضمان المشاركة في المزاد', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('يتم حجز مبلغ مؤقت لضمان جدية المزايدة ويُعاد تلقائيًا إذا لم تفز.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.6)),
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    _InfoRow(Icons.payments_outlined, 'قيمة الضمان', '250 ر.س'),
                    Divider(height: 17),
                    _InfoRow(Icons.lock_clock_outlined, 'نوع العملية', 'حجز مؤقت'),
                    Divider(height: 17),
                    _InfoRow(Icons.replay_rounded, 'الاسترداد', 'فوري عند انتهاء المشاركة'),
                    Divider(height: 17),
                    _InfoRow(Icons.verified_user_outlined, 'الحماية', 'عملية آمنة ومشفرة'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: const Color(0xFFF8F0DC), borderRadius: BorderRadius.circular(13)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.terracotta),
                    SizedBox(width: 7),
                    Expanded(child: Text('عند الفوز، يمكن احتساب الضمان ضمن المبلغ المطلوب حسب شروط المزاد.', style: TextStyle(fontSize: 10, height: 1.55))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/auction-bid'),
                  child: const Text('المتابعة إلى المزايدة', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      );
}

class _AuctionHeader extends StatelessWidget {
  const _AuctionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const AppLogo(size: 49),
            PositionedDirectional(
              end: 13,
              child: Row(
                children: [
                  Text(title, style: const TextStyle(color: AppColors.forestDark, fontSize: 23, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 6),
                  const Icon(Icons.gavel_rounded, color: AppColors.forestDark),
                ],
              ),
            ),
            PositionedDirectional(
              start: 6,
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, '/auction-reminder'),
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.forestDark),
              ),
            ),
          ],
        ),
      );
}

class _AuctionMini extends StatelessWidget {
  const _AuctionMini({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(width: 94, height: 78, child: AppDataImage(auction.image, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  const Text('4,200 ر.س', style: TextStyle(color: AppColors.forest, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  const Text('متبقي 02:14:16', style: TextStyle(color: AppColors.terracotta, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon, this.color = AppColors.forest});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 3),
          Text(value, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w900)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 8.5)),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.forest, size: 19),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppColors.forestDark, fontSize: 10.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.forestDark, size: 20),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      );
}

class _PriceBox extends StatelessWidget {
  const _PriceBox(this.value);

  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
      );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.forestDark, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class _AuctionBottomNav extends StatelessWidget {
  const _AuctionBottomNav({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    const items = <({String label, IconData icon, String route})>[
      (label: 'الرئيسية', icon: Icons.home_outlined, route: '/'),
      (label: 'المنتجات', icon: Icons.grid_view_outlined, route: '/products'),
      (label: 'المزادات', icon: Icons.gavel_rounded, route: '/auctions'),
      (label: 'سلة التسوق', icon: Icons.shopping_cart_outlined, route: '/cart'),
      (label: 'حسابي', icon: Icons.person_outline_rounded, route: '/account'),
    ];
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == active;
              return Expanded(
                child: InkWell(
                  onTap: selected
                      ? null
                      : () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            item.route,
                            (route) => item.route != '/' && route.isFirst,
                          ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: selected ? AppColors.forest : AppColors.muted, size: 22),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: selected ? AppColors.forest : AppColors.muted,
                          fontSize: 9,
                          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
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
