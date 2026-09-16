import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/my_auction_repository.dart';

class ConnectedMyAuctionsScreen extends StatefulWidget {
  const ConnectedMyAuctionsScreen({super.key, this.historyOnly = false});
  final bool historyOnly;

  @override
  State<ConnectedMyAuctionsScreen> createState() =>
      _ConnectedMyAuctionsScreenState();
}

class _ConnectedMyAuctionsScreenState extends State<ConnectedMyAuctionsScreen> {
  String filter = '';
  bool loading = true;
  String? error;
  List<MyAuctionBidData> items = const [];

  @override
  void initState() {
    super.initState();
    if (widget.historyOnly) filter = 'lost';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading && items.isEmpty && error == null) _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await MyAuctionRepository(AppScope.of(context).client)
          .fetchMine(result: filter.isEmpty ? null : filter);
      if (mounted) setState(() => items = data);
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException
            ? e.message
            : 'تعذر تحميل مزاداتك.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _select(String value) async {
    if (filter == value) return;
    setState(() => filter = value);
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MazraaAppBar(
          title: widget.historyOnly ? 'سجل المزايدات' : 'مزاداتي',
        ),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.historyOnly)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 7,
                    children: [
                      ChoiceChip(
                        label: const Text('الكل'),
                        selected: filter.isEmpty,
                        onSelected: (_) => _select(''),
                      ),
                      ChoiceChip(
                        label: const Text('نشطة'),
                        selected: filter == 'active',
                        onSelected: (_) => _select('active'),
                      ),
                      ChoiceChip(
                        label: const Text('فزت'),
                        selected: filter == 'won',
                        onSelected: (_) => _select('won'),
                      ),
                      ChoiceChip(
                        label: const Text('انتهت بدون فوز'),
                        selected: filter == 'lost',
                        onSelected: (_) => _select('lost'),
                      ),
                    ],
                  ),
                ),
              if (!widget.historyOnly) const SizedBox(height: 12),
              if (loading)
                const LinearProgressIndicator()
              else if (error != null)
                ResultStateView(
                  kind: ResultKind.error,
                  title: 'تعذر تحميل مزاداتك',
                  message: error!,
                  primaryLabel: 'إعادة المحاولة',
                  onPrimary: _load,
                )
              else if (items.isEmpty)
                const ResultStateView(
                  kind: ResultKind.empty,
                  title: 'لا توجد مزايدات',
                  message: 'ستظهر هنا المزادات التي شاركت فيها بحسابك.',
                )
              else
                ...items.map(
                  (bid) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: bid.isWinner
                                    ? AppColors.forestSoft
                                    : AppColors.terracotta.withValues(alpha: .10),
                                child: Icon(
                                  bid.isWinner
                                      ? Icons.emoji_events_rounded
                                      : Icons.gavel_rounded,
                                  color: bid.isWinner
                                      ? AppColors.forest
                                      : AppColors.terracotta,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bid.auctionTitle.isEmpty
                                          ? 'مزاد #${bid.auctionId}'
                                          : bid.auctionTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    if (bid.animalName.isNotEmpty)
                                      Text(
                                        bid.animalName,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              StatusPill(
                                label: bid.isWinner
                                    ? 'فائز'
                                    : _statusLabel(bid.auctionStatus),
                                color: bid.isWinner
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ],
                          ),
                          const Divider(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: _Value(
                                  title: 'مزايدتك',
                                  value: formatPrice(bid.bidAmount),
                                ),
                              ),
                              Expanded(
                                child: _Value(
                                  title: 'السعر الحالي',
                                  value: formatPrice(bid.currentPrice),
                                ),
                              ),
                            ],
                          ),
                          if (bid.bidAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'آخر مزايدة: ${_date(bid.bidAt!)}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _Value extends StatelessWidget {
  const _Value({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.forest,
            ),
          ),
        ],
      );
}

String _statusLabel(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('active') || normalized == '1') return 'نشط';
  if (normalized.contains('ended') || normalized == '2') return 'منتهي';
  if (normalized.contains('cancel')) return 'ملغي';
  return value.isEmpty ? 'مزاد' : value;
}

String _date(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
