import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

class AuctionListScreen extends StatefulWidget {
  const AuctionListScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<AuctionListScreen> createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends State<AuctionListScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final auctions = AppScope.of(context).auctions;
    final body = AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'المزادات',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const AuctionFilterSheet(),
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('مباشر')),
              ButtonSegment(value: 1, label: Text('قادم')),
              ButtonSegment(value: 2, label: Text('منتهي')),
            ],
            selected: {tab},
            showSelectedIcon: false,
            onSelectionChanged: (value) => setState(() => tab = value.first),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                FilterChip(
                  label: Text('حيوانات'),
                  selected: true,
                  onSelected: null,
                ),
                SizedBox(width: 7),
                FilterChip(
                  label: Text('منتجات زراعية'),
                  selected: false,
                  onSelected: null,
                ),
                SizedBox(width: 7),
                FilterChip(
                  label: Text('معدات'),
                  selected: false,
                  onSelected: null,
                ),
                SizedBox(width: 7),
                FilterChip(
                  label: Text('مستلزمات النحل'),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .69,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: auctions.length,
            itemBuilder: (_, i) => AuctionCard(
              auction: auctions[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AuctionDetailsScreen(auction: auctions[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.embedded) {
      return Scaffold(appBar: const MazraaAppBar(), body: body);
    }
    return Scaffold(appBar: const MazraaAppBar(), body: body);
  }
}

class AuctionFilterSheet extends StatefulWidget {
  const AuctionFilterSheet({super.key});
  @override
  State<AuctionFilterSheet> createState() => _AuctionFilterSheetState();
}

class _AuctionFilterSheetState extends State<AuctionFilterSheet> {
  RangeValues value = const RangeValues(1000, 8000);
  bool delivery = true;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'تصفية المزادات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('مسح الكل')),
              ],
            ),
            const SectionHeader(title: 'الفئات', icon: Icons.grid_view_rounded),
            const Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                ChoiceChip(label: Text('حيوانات'), selected: true),
                ChoiceChip(label: Text('منتجات زراعية'), selected: false),
                ChoiceChip(label: Text('معدات'), selected: false),
                ChoiceChip(label: Text('مستلزمات النحل'), selected: false),
              ],
            ),
            const SizedBox(height: 14),
            const SectionHeader(
              title: 'الموقع',
              icon: Icons.location_on_outlined,
            ),
            const DropdownMenu<String>(
              width: 340,
              initialSelection: 'الرياض',
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 'الرياض', label: 'الرياض'),
                DropdownMenuEntry(value: 'جدة', label: 'جدة'),
                DropdownMenuEntry(value: 'القصيم', label: 'القصيم'),
              ],
            ),
            const SizedBox(height: 14),
            const SectionHeader(title: 'نطاق السعر', icon: Icons.sell_outlined),
            RangeSlider(
              values: value,
              min: 0,
              max: 10000,
              divisions: 20,
              onChanged: (v) => setState(() => value = v),
            ),
            SwitchListTile(
              value: delivery,
              onChanged: (v) => setState(() => delivery = v),
              title: const Text('التوصيل متوفر'),
              secondary: const Icon(Icons.local_shipping_outlined),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('عرض المزادات'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AuctionDetailsScreen extends StatelessWidget {
  const AuctionDetailsScreen({super.key, required this.auction});
  final Auction auction;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MazraaAppBar(
      title: 'تفاصيل المزاد',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border_rounded),
        ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuctionReminderScreen(auction: auction),
                  ),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
                label: const Text('متابعة فقط'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BidScreen(auction: auction),
                  ),
                ),
                icon: const Icon(Icons.gavel_rounded),
                label: const Text('المزايدة الآن'),
              ),
            ),
          ],
        ),
      ),
    ),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.45,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(auction.image, fit: BoxFit.cover),
                ),
              ),
              const PositionedDirectional(
                top: 10,
                start: 10,
                child: StatusPill(
                  label: 'مزاد مباشر',
                  color: AppColors.terracotta,
                  icon: Icons.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, _) => ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(auction.image, width: 72, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(auction.title, style: Theme.of(context).textTheme.titleLarge),
          Text(
            auction.category,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            color: AppColors.forestSoft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('السعر الحالي'),
                    Text(
                      formatPrice(auction.currentBid),
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: AppColors.forest),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('الوقت المتبقي'),
                    AuctionTimer(duration: auction.remaining, small: false),
                  ],
                ),
                Column(
                  children: [
                    const Text('المزايدون'),
                    Text(
                      '${auction.bidCount}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Icon(Icons.verified_user_outlined),
                      Text('بائع موثوق', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Icon(Icons.local_shipping_outlined),
                      Text('توصيل متاح', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined),
                      Text('جودة مفحوصة', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingsTile(
            icon: Icons.storefront_outlined,
            title: 'مزرعة الأصالة',
            subtitle: 'بائع موثوق • تقييم 4.8',
            onTap: () {},
          ),
          const SizedBox(height: 9),
          const SectionHeader(
            title: 'شروط المزاد',
            icon: Icons.description_outlined,
          ),
          const AppSurfaceCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.payments_outlined),
                  title: Text('حجز مبلغ ضمان قبل المزايدة'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.schedule_rounded),
                  title: Text('السداد خلال 24 ساعة من الفوز'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.local_shipping_outlined),
                  title: Text('التسليم متاح داخل المدينة'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionHeader(title: 'الوصف', icon: Icons.eco_rounded),
          const Text(
            'معروض بعناية وبحالة ممتازة. تمت معاينته من فريق مزرعتي وتوثيق بياناته الأساسية قبل بدء المزاد.',
          ),
        ],
      ),
    ),
  );
}

class BidScreen extends StatefulWidget {
  const BidScreen({super.key, required this.auction});
  final Auction auction;
  @override
  State<BidScreen> createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  late double amount = widget.auction.currentBid + 200;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تقديم مزايدة'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSurfaceCard(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.auction.image,
                    width: 112,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.auction.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      AuctionTimer(duration: widget.auction.remaining),
                      Text(
                        'السعر الحالي ${formatPrice(widget.auction.currentBid)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'قيمة المزايدة',
            icon: Icons.gavel_rounded,
          ),
          AppSurfaceCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => setState(() => amount -= 50),
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        formatPrice(amount),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => setState(() => amount += 50),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [100, 250, 500]
                      .map(
                        (e) => ActionChip(
                          label: Text('+$e'),
                          onPressed: () => setState(() => amount += e),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const AppSurfaceCard(
            color: AppColors.forestSoft,
            child: ListTile(
              leading: Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.forest,
              ),
              title: Text('رصيد المحفظة'),
              trailing: Text('2,850 ر.س'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.gavel_rounded),
            label: const Text('متابعة المزايدة'),
          ),
          const SizedBox(height: 12),
          const AppSurfaceCard(
            color: AppColors.terracottaSoft,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.terracotta),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'بمتابعة العملية فأنت توافق على شروط المزاد، ولا يمكن سحب العرض بعد تأكيده.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  void _confirm() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.gavel_rounded, color: AppColors.forest, size: 52),
            const SizedBox(height: 8),
            Text(
              'تأكيد المزايدة',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(widget.auction.title, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppSurfaceCard(
              color: AppColors.forestSoft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('قيمة المزايدة'),
                  Text(
                    formatPrice(amount),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AuctionResultScreen(auction: widget.auction),
                        ),
                      );
                    },
                    child: const Text('تأكيد المزايدة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class AuctionResultScreen extends StatelessWidget {
  const AuctionResultScreen({
    super.key,
    required this.auction,
    this.kind = AuctionResultKind.success,
  });
  final Auction auction;
  final AuctionResultKind kind;
  @override
  Widget build(BuildContext context) {
    final (title, message, result) = switch (kind) {
      AuctionResultKind.success => (
        'تمت المزايدة بنجاح',
        'أنت الآن صاحب أعلى مزايدة، سنخبرك فور حدوث أي تغيير.',
        ResultKind.success,
      ),
      AuctionResultKind.won => (
        'مبروك! فزت بالمزاد',
        'أكمل سداد المبلغ المتبقي لحجز المنتج.',
        ResultKind.success,
      ),
      AuctionResultKind.ended => (
        'انتهى المزاد',
        'لم تكن هذه المرة، تصفح مزادات مشابهة وجرّب مجددًا.',
        ResultKind.empty,
      ),
    };
    return Scaffold(
      appBar: const MazraaAppBar(),
      body: ResultStateView(
        kind: result,
        title: title,
        message: message,
        primaryLabel: kind == AuctionResultKind.won
            ? 'سداد المبلغ المتبقي'
            : 'متابعة المزاد',
        onPrimary: () => Navigator.pop(context),
        secondaryLabel: 'العودة للمزادات',
        onSecondary: () =>
            Navigator.popUntil(context, (route) => route.isFirst),
        details: AppSurfaceCard(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  auction.image,
                  width: 70,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(auction.title)),
              Text(formatPrice(auction.currentBid)),
            ],
          ),
        ),
      ),
    );
  }
}

enum AuctionResultKind { success, won, ended }

class AuctionReminderScreen extends StatelessWidget {
  const AuctionReminderScreen({super.key, required this.auction});
  final Auction auction;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: ResultStateView(
      kind: ResultKind.success,
      title: 'تم ضبط التذكير',
      message: 'سنرسل تذكيرًا قبل موعد المزاد بوقت كافٍ.',
      primaryLabel: 'إلغاء التذكير',
      onPrimary: () => Navigator.pop(context),
      secondaryLabel: 'تصفح المزاد',
      onSecondary: () => Navigator.pop(context),
      details: AppSurfaceCard(
        child: Column(
          children: [
            Image.asset(
              auction.image,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(auction.title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    ),
  );
}

class MyAuctionsScreen extends StatelessWidget {
  const MyAuctionsScreen({super.key, this.history = false});
  final bool history;
  @override
  Widget build(BuildContext context) {
    final auctions = AppScope.of(context).auctions;
    return Scaffold(
      appBar: MazraaAppBar(title: history ? 'سجل المزايدات' : 'مزاداتي'),
      body: AppPage(
        child: Column(
          children: [
            const Wrap(
              spacing: 7,
              children: [
                ChoiceChip(label: Text('الكل'), selected: true),
                ChoiceChip(label: Text('مشارك فيها'), selected: false),
                ChoiceChip(label: Text('تم الفوز'), selected: false),
                ChoiceChip(label: Text('منتهية'), selected: false),
              ],
            ),
            const SizedBox(height: 12),
            ...auctions.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: AuctionCard(
                  auction: a,
                  compact: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuctionDetailsScreen(auction: a),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuaranteeDetailsScreen extends StatelessWidget {
  const GuaranteeDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auction = AppScope.of(context).auctions.first;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'تفاصيل حجز الضمان'),
      body: AppPage(
        child: Column(
          children: [
            AppSurfaceCard(
              child: Row(
                children: [
                  Image.asset(
                    auction.image,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      auction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const AppSurfaceCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet_outlined),
                    title: Text('المبلغ المحجوز'),
                    trailing: Text('250 ر.س'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.payments_outlined),
                    title: Text('الرصيد الحالي'),
                    trailing: Text('2,600 ر.س'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.description_outlined),
                    title: Text('سبب الحجز'),
                    subtitle: Text('حجز ضمان المزايدة'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.verified_user_outlined),
                    title: Text('شروط الإرجاع'),
                    subtitle: Text(
                      'يعاد المبلغ عند عدم الفوز أو اكتمال السداد',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة للمحفظة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
