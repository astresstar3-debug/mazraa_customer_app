import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

class ConnectedAuctionListScreen extends StatefulWidget {
  const ConnectedAuctionListScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ConnectedAuctionListScreen> createState() => _ConnectedAuctionListScreenState();
}

class _ConnectedAuctionListScreenState extends State<ConnectedAuctionListScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final state = switch (tab) {
      1 => AuctionState.upcoming,
      2 => AuctionState.ended,
      _ => AuctionState.live,
    };
    final auctions = app.auctions.where((auction) => auction.state == state).toList();

    return Scaffold(
      appBar: const MazraaAppBar(),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'المزادات',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.forest),
                ),
                const Spacer(),
                IconButton(
                  onPressed: app.initialize,
                  icon: const Icon(Icons.refresh_rounded),
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
            const SizedBox(height: 12),
            if (app.isLoading && app.auctions.isEmpty)
              const LinearProgressIndicator()
            else if (auctions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 46),
                child: Center(child: Text('لا توجد مزادات في هذه الحالة حاليًا')),
              )
            else
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
                      builder: (_) => ConnectedAuctionDetailsScreen(
                        auction: auctions[i],
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

class ConnectedAuctionDetailsScreen extends StatelessWidget {
  const ConnectedAuctionDetailsScreen({super.key, required this.auction});
  final Auction auction;

  @override
  Widget build(BuildContext context) {
    final canBid = auction.state == AuctionState.live;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'تفاصيل المزاد'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: canBid
                ? () {
                    final app = AppScope.of(context);
                    if (!app.isAuthenticated) {
                      Navigator.pushNamed(context, '/login');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectedBidScreen(auction: auction),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.gavel_rounded),
            label: Text(canBid ? 'المزايدة الآن' : 'المزاد غير متاح للمزايدة'),
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
                    child: AppDataImage(auction.image, fit: BoxFit.cover),
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: StatusPill(
                    label: switch (auction.state) {
                      AuctionState.live => 'مزاد مباشر',
                      AuctionState.upcoming => 'مزاد قادم',
                      AuctionState.ended => 'مزاد منتهي',
                      AuctionState.won => 'تم الفوز',
                    },
                    color: auction.state == AuctionState.live
                        ? AppColors.terracotta
                        : AppColors.forest,
                    icon: Icons.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(auction.title, style: Theme.of(context).textTheme.titleLarge),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: AppColors.forest),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('الوقت المتبقي'),
                      AuctionTimer(duration: auction.remaining),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('المزايدات'),
                      Text(
                        '${auction.bidCount}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SectionHeader(title: 'الوصف', icon: Icons.description_outlined),
            AppSurfaceCard(
              child: Text(
                auction.description.trim().isEmpty
                    ? 'لا يوجد وصف إضافي لهذا المزاد.'
                    : auction.description,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectedBidScreen extends StatefulWidget {
  const ConnectedBidScreen({super.key, required this.auction});
  final Auction auction;

  @override
  State<ConnectedBidScreen> createState() => _ConnectedBidScreenState();
}

class _ConnectedBidScreenState extends State<ConnectedBidScreen> {
  int? auctionItemId;
  double currentPrice = 0;
  double amount = 0;
  bool loading = true;
  bool submitting = false;
  String? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading && auctionItemId == null && error == null) _loadItem();
  }

  Future<void> _loadItem() async {
    final client = AppScope.of(context).client;
    try {
      final response = await client.get('/api/AuctionItems/auction/${widget.auction.id}');
      if (response is! List || response.isEmpty) {
        throw const ApiException('لا يحتوي المزاد على عنصر متاح للمزايدة.');
      }
      final item = jsonMap(response.first);
      final itemId = _asInt(jsonValue(item, 'id'));
      if (itemId == null) {
        throw const ApiException('تعذر تحديد عنصر المزاد.');
      }
      var price = _asDouble(jsonValue(item, 'startPrice')) ?? widget.auction.currentBid;
      final bids = await client.get('/api/AuctionBids/auction-item/$itemId');
      if (bids is List) {
        for (final row in bids) {
          final bid = jsonMap(row);
          final bidAmount = _asDouble(jsonValue(bid, 'bidAmount'));
          if (bidAmount != null && bidAmount > price) price = bidAmount;
        }
      }
      if (!mounted) return;
      setState(() {
        auctionItemId = itemId;
        currentPrice = price;
        amount = price + 50;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e is ApiException ? e.message : 'تعذر تحميل بيانات المزايدة.';
        loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final itemId = auctionItemId;
    if (itemId == null) return;
    if (amount <= currentPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن تكون المزايدة أعلى من السعر الحالي.')),
      );
      return;
    }

    final app = AppScope.of(context);
    if (!app.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => submitting = true);
    try {
      await app.client.post('/api/AuctionBids', body: {
        'auctionItemId': itemId,
        'bidderUserId': 0,
        'bidAmount': amount,
      });
      await app.initialize();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _BidSuccessScreen(
            auction: widget.auction,
            amount: amount,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : 'تعذر إرسال المزايدة.'),
        ),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

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
                      child: AppDataImage(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (loading)
                const LinearProgressIndicator()
              else if (error != null)
                AppSurfaceCard(
                  child: Column(
                    children: [
                      Text(error!, textAlign: TextAlign.center),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            error = null;
                          });
                          _loadItem();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              else ...[
                SectionHeader(
                  title: 'السعر الحالي ${formatPrice(currentPrice)}',
                  icon: Icons.gavel_rounded,
                ),
                AppSurfaceCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            onPressed: amount - 50 > currentPrice
                                ? () => setState(() => amount -= 50)
                                : null,
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
                              (value) => ActionChip(
                                label: Text('+$value'),
                                onPressed: () => setState(() => amount += value),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: submitting ? null : _submit,
                  icon: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.gavel_rounded),
                  label: const Text('تأكيد المزايدة'),
                ),
              ],
            ],
          ),
        ),
      );

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }
}

class _BidSuccessScreen extends StatelessWidget {
  const _BidSuccessScreen({required this.auction, required this.amount});
  final Auction auction;
  final double amount;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(),
        body: ResultStateView(
          kind: ResultKind.success,
          title: 'تم إرسال المزايدة بنجاح',
          message: 'تم تسجيل مزايدتك لدى الخادم.',
          primaryLabel: 'العودة للمزادات',
          onPrimary: () => Navigator.of(context).popUntil((route) => route.isFirst),
          details: AppSurfaceCard(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppDataImage(
                    auction.image,
                    width: 70,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(auction.title)),
                Text(formatPrice(amount)),
              ],
            ),
          ),
        ),
      );
}
