import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class ConnectedCouponsScreen extends StatefulWidget {
  const ConnectedCouponsScreen({super.key});

  @override
  State<ConnectedCouponsScreen> createState() => _ConnectedCouponsScreenState();
}

class _ConnectedCouponsScreenState extends State<ConnectedCouponsScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> coupons = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading && coupons.isEmpty && error == null) _load();
  }

  Future<void> _load() async {
    try {
      final response = await AppScope.of(context).client.get('/api/Coupons');
      if (!mounted) return;
      setState(() {
        coupons = response is List
            ? response.map((e) => jsonMap(e)).toList()
            : const [];
      });
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر تحميل الكوبونات.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'الكوبونات'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loading)
                const LinearProgressIndicator()
              else if (error != null)
                ResultStateView(
                  kind: ResultKind.error,
                  title: 'تعذر تحميل الكوبونات',
                  message: error!,
                  primaryLabel: 'إعادة المحاولة',
                  onPrimary: () {
                    setState(() {
                      loading = true;
                      error = null;
                    });
                    _load();
                  },
                )
              else if (coupons.isEmpty)
                const ResultStateView(
                  kind: ResultKind.empty,
                  title: 'لا توجد كوبونات متاحة',
                  message: 'ستظهر هنا الكوبونات النشطة التي يعيدها الخادم.',
                )
              else
                ...coupons.map((coupon) {
                  final code = '${jsonValue(coupon, 'code') ?? ''}';
                  final name = '${jsonValue(coupon, 'name') ?? code}';
                  final description = '${jsonValue(coupon, 'description') ?? ''}';
                  final value = jsonValue(coupon, 'discountValue');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_offer_outlined,
                                  color: AppColors.forest),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(name,
                                    style: Theme.of(context).textTheme.titleMedium),
                              ),
                              if (value != null)
                                StatusPill(label: '$value'),
                            ],
                          ),
                          if (code.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            SelectableText(
                              code,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.terracotta,
                              ),
                            ),
                          ],
                          if (description.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(description),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              if (!loading && coupons.isNotEmpty) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/checkout'),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: const Text('استخدام كوبون في إتمام الشراء'),
                ),
              ],
            ],
          ),
        ),
      );
}
