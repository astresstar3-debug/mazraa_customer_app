import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/checkout_repository.dart';

class ConnectedEnhancedCheckoutScreen extends StatefulWidget {
  const ConnectedEnhancedCheckoutScreen({super.key});

  @override
  State<ConnectedEnhancedCheckoutScreen> createState() =>
      _ConnectedEnhancedCheckoutScreenState();
}

class _ConnectedEnhancedCheckoutScreenState
    extends State<ConnectedEnhancedCheckoutScreen> {
  final couponController = TextEditingController();
  List<DeliveryAddress> addresses = const [];
  List<Map<String, dynamic>> coupons = const [];
  int? selectedAddressId;
  int paymentMethod = 3;
  bool loading = true;
  bool checkingCoupon = false;
  bool submitting = false;
  String? error;
  String? acceptedCoupon;
  Map<String, dynamic>? quote;

  CheckoutRepository? repository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (repository == null) {
      repository = CheckoutRepository(AppScope.of(context).client);
      _load();
    }
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    try {
      final values = await Future.wait<dynamic>([
        repository!.fetchAddresses(),
        app.client.get('/api/Coupons'),
      ]);
      final rawCoupons = values[1];
      if (!mounted) return;
      setState(() {
        addresses = values[0] as List<DeliveryAddress>;
        selectedAddressId = addresses.isEmpty ? null : addresses.first.id;
        coupons = rawCoupons is List
            ? rawCoupons.map((e) => jsonMap(e)).toList()
            : const [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e is ApiException ? e.message : 'تعذر تحميل بيانات الدفع.';
      });
    }
  }

  Future<void> _applyCoupon([String? selectedCode]) async {
    final code = (selectedCode ?? couponController.text).trim();
    if (code.isEmpty) {
      setState(() => error = 'أدخل رمز الكوبون.');
      return;
    }
    if (selectedAddressId == null) {
      setState(() => error = 'اختر عنوان التوصيل قبل تطبيق الكوبون.');
      return;
    }
    setState(() {
      checkingCoupon = true;
      error = null;
      acceptedCoupon = null;
      quote = null;
      couponController.text = code;
    });
    try {
      final response = jsonMap(
        await AppScope.of(context).client.post(
          '/api/cart/apply-coupon',
          body: {
            'couponCode': code,
            'addressId': selectedAddressId,
            'deliveryZoneId': null,
          },
        ),
      );
      if (!mounted) return;
      setState(() {
        acceptedCoupon = code;
        quote = response;
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiException ? e.message : 'تعذر تطبيق الكوبون.',
        );
      }
    } finally {
      if (mounted) setState(() => checkingCoupon = false);
    }
  }

  Future<void> _submit() async {
    final app = AppScope.of(context);
    if (!app.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    if (selectedAddressId == null) {
      setState(() => error = 'أضف عنوان توصيل أولًا.');
      return;
    }
    if (app.cart.isEmpty) return;

    setState(() {
      submitting = true;
      error = null;
    });
    try {
      final order = await repository!.createOrder(
        userId: app.session?.userId ?? 0,
        addressId: selectedAddressId!,
        lines: app.cart,
        paymentMethod: paymentMethod,
        couponCode: acceptedCoupon,
      );
      await Future.wait<void>([app.refreshCart(), app.refreshOrders()]);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _CheckoutSuccessScreen(order: order)),
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiException ? e.message : 'تعذر إنشاء الطلب.',
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'إتمام الشراء'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: loading || submitting ? null : _submit,
            icon: submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_user_outlined),
            label: const Text('تأكيد الطلب'),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'عنوان التوصيل',
                    icon: Icons.location_on_outlined,
                  ),
                  if (addresses.isEmpty)
                    AppSurfaceCard(
                      child: Column(
                        children: [
                          const Text('لا يوجد عنوان توصيل محفوظ.'),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/add-address',
                              );
                              if (mounted) _load();
                            },
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: const Text('إضافة عنوان'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...addresses.map(
                      (address) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppSurfaceCard(
                          color: selectedAddressId == address.id
                              ? AppColors.forestSoft
                              : null,
                          child: RadioListTile<int>(
                            value: address.id,
                            groupValue: selectedAddressId,
                            onChanged: (value) => setState(() {
                              selectedAddressId = value;
                              acceptedCoupon = null;
                              quote = null;
                            }),
                            title: Text(address.city),
                            subtitle: Text(address.label),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const SectionHeader(
                    title: 'الكوبون',
                    icon: Icons.discount_outlined,
                  ),
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        TextField(
                          controller: couponController,
                          decoration: const InputDecoration(
                            labelText: 'رمز الكوبون',
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: checkingCoupon ? null : _applyCoupon,
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                            ),
                            label: Text(
                              checkingCoupon
                                  ? 'جاري التحقق...'
                                  : 'التحقق وتطبيق الكوبون',
                            ),
                          ),
                        ),
                        if (acceptedCoupon != null) ...[
                          const SizedBox(height: 8),
                          StatusPill(
                            label: 'تم قبول الكوبون: $acceptedCoupon',
                            icon: Icons.verified_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (coupons.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: coupons.map((item) {
                        final code = '${jsonValue(item, 'code') ?? ''}';
                        if (code.isEmpty) return const SizedBox.shrink();
                        return ActionChip(
                          label: Text(code),
                          onPressed: () => _applyCoupon(code),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const SectionHeader(
                    title: 'طريقة الدفع',
                    icon: Icons.payments_outlined,
                  ),
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        _paymentTile(
                          3,
                          'الدفع عند الاستلام',
                          Icons.payments_outlined,
                        ),
                        _paymentTile(
                          2,
                          'المحفظة الداخلية',
                          Icons.account_balance_wallet_outlined,
                        ),
                        _paymentTile(
                          4,
                          'تحويل بنكي',
                          Icons.account_balance_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SectionHeader(
                    title: 'ملخص التكلفة',
                    icon: Icons.receipt_long_outlined,
                  ),
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        _row('المجموع قبل الخصم', formatPrice(app.subtotal)),
                        if (quote != null)
                          ...quote!.entries
                              .where((e) => e.value is num)
                              .take(6)
                              .map(
                                (e) => _row(_quoteLabel(e.key), '${e.value}'),
                              ),
                        const Divider(),
                        const Text(
                          'القيمة النهائية والخصم ورسوم التوصيل يحتسبها الخادم عند إنشاء الطلب.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _paymentTile(int value, String title, IconData icon) =>
      RadioListTile<int>(
        value: value,
        groupValue: paymentMethod,
        onChanged: (next) =>
            setState(() => paymentMethod = next ?? paymentMethod),
        secondary: Icon(icon),
        title: Text(title),
      );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );

  String _quoteLabel(String key) {
    const labels = {
      'subtotal': 'المجموع الفرعي',
      'discount': 'الخصم',
      'discountAmount': 'قيمة الخصم',
      'shipping': 'رسوم التوصيل',
      'shippingFee': 'رسوم التوصيل',
      'total': 'الإجمالي',
      'totalAmount': 'الإجمالي',
    };
    return labels[key] ?? key;
  }
}

class _CheckoutSuccessScreen extends StatelessWidget {
  const _CheckoutSuccessScreen({required this.order});
  final CreatedOrder order;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تم إنشاء الطلب'),
    body: ResultStateView(
      kind: ResultKind.success,
      title: 'تم إنشاء طلبك بنجاح',
      message: 'رقم الطلب #${order.id} • الإجمالي ${formatPrice(order.total)}',
      primaryLabel: 'عرض الطلبات',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(
        context,
        '/orders',
        (route) => route.isFirst,
      ),
      secondaryLabel: 'العودة للرئيسية',
      onSecondary: () => Navigator.popUntil(context, (route) => route.isFirst),
    ),
  );
}
