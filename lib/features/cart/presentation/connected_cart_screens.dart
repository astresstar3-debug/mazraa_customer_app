import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';
import '../data/checkout_repository.dart';

class ConnectedCartScreen extends StatelessWidget {
  const ConnectedCartScreen({super.key, this.embedded = false, this.forceEmpty = false});
  final bool embedded;
  final bool forceEmpty;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final lines = forceEmpty ? <CartLine>[] : app.cart;
    if (!app.isAuthenticated && lines.isEmpty) {
      return Scaffold(
        appBar: const MazraaAppBar(title: 'سلة التسوق'),
        body: ResultStateView(
          kind: ResultKind.empty,
          title: 'سجّل الدخول لعرض سلة التسوق',
          message: 'تتم مزامنة سلتك مع حسابك على الخادم.',
          primaryLabel: 'تسجيل الدخول',
          onPrimary: () => Navigator.pushNamed(context, '/login'),
          secondaryLabel: 'تصفح المنتجات',
          onSecondary: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      );
    }

    return Scaffold(
      appBar: MazraaAppBar(
        title: lines.isEmpty ? 'سلة التسوق' : 'سلة التسوق  ${app.cartCount}',
      ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/checkout'),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: Text('إتمام الشراء • ${formatPrice(app.subtotal)}'),
                ),
              ),
            ),
      body: lines.isEmpty
          ? const ResultStateView(
              kind: ResultKind.empty,
              title: 'سلتك فارغة',
              message: 'أضف منتجاتك المفضلة وابدأ التسوق',
              primaryLabel: 'تصفح المنتجات',
            )
          : AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...lines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: AppSurfaceCard(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: AppDataImage(
                                line.product.image,
                                width: 88,
                                height: 82,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.product.name,
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formatPrice(line.product.price),
                                    style: const TextStyle(
                                      color: AppColors.terracotta,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  QuantityStepper(
                                    value: line.quantity,
                                    onChanged: (value) =>
                                        app.setQuantity(line.product, value),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => app.setQuantity(line.product, 0),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.terracotta,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        _cost('المجموع الفرعي', app.subtotal),
                        const Divider(),
                        _cost('الإجمالي', app.subtotal, bold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  static Widget _cost(String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null)),
            const Spacer(),
            Text(
              formatPrice(value),
              style: TextStyle(fontWeight: bold ? FontWeight.w800 : null),
            ),
          ],
        ),
      );
}

class ConnectedCheckoutScreen extends StatefulWidget {
  const ConnectedCheckoutScreen({super.key});

  @override
  State<ConnectedCheckoutScreen> createState() => _ConnectedCheckoutScreenState();
}

class _ConnectedCheckoutScreenState extends State<ConnectedCheckoutScreen> {
  List<DeliveryAddress> addresses = const [];
  int? selectedAddressId;
  int paymentMethod = 3;
  bool loading = true;
  bool submitting = false;
  String? error;

  CheckoutRepository? _repository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repository == null) {
      _repository = CheckoutRepository(AppScope.of(context).client);
      _loadAddresses();
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final data = await _repository!.fetchAddresses();
      if (!mounted) return;
      setState(() {
        addresses = data;
        selectedAddressId = data.isEmpty ? null : data.first.id;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e is ApiException ? e.message : 'تعذر تحميل عناوين التوصيل.';
      });
    }
  }

  Future<void> _submit() async {
    final app = AppScope.of(context);
    if (!app.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف عنوان توصيل أولًا.')),
      );
      return;
    }
    if (app.cart.isEmpty) return;

    setState(() => submitting = true);
    try {
      final order = await _repository!.createOrder(
        userId: app.session?.userId ?? 0,
        addressId: selectedAddressId!,
        lines: app.cart,
        paymentMethod: paymentMethod,
      );
      await app.refreshCart();
      await app.refreshOrders();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _ConnectedOrderSuccessScreen(order: order),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'تعذر إنشاء الطلب.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            onPressed: submitting || loading ? null : _submit,
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
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'ملخص الطلب',
              icon: Icons.shopping_bag_outlined,
            ),
            AppSurfaceCard(
              child: Column(
                children: app.cart
                    .map(
                      (line) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppDataImage(
                            line.product.image,
                            width: 56,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(line.product.name),
                        subtitle: Text('${line.quantity} ×'),
                        trailing: Text(
                          formatPrice(line.product.price * line.quantity),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'عنوان التوصيل',
              icon: Icons.location_on_outlined,
            ),
            if (loading)
              const LinearProgressIndicator()
            else if (error != null)
              AppSurfaceCard(
                child: Column(
                  children: [
                    Text(error!, textAlign: TextAlign.center),
                    TextButton.icon(
                      onPressed: _loadAddresses,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            else if (addresses.isEmpty)
              AppSurfaceCard(
                child: Column(
                  children: [
                    const Text('لا يوجد عنوان توصيل محفوظ.'),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/add-address');
                        if (mounted) _loadAddresses();
                      },
                      icon: const Icon(Icons.add_location_alt_rounded),
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
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => setState(() => selectedAddressId = address.id),
                      leading: const Icon(Icons.home_rounded),
                      title: Text(address.city),
                      subtitle: Text(address.label),
                      trailing: Icon(
                        selectedAddressId == address.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selectedAddressId == address.id
                            ? AppColors.forest
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            if (addresses.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/add-address');
                    if (mounted) _loadAddresses();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة عنوان آخر'),
                ),
              ),
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'طريقة الدفع',
              icon: Icons.credit_card_rounded,
            ),
            AppSurfaceCard(
              child: Column(
                children: [
                  ListTile(
                    onTap: () => setState(() => paymentMethod = 3),
                    title: const Text('الدفع عند الاستلام'),
                    leading: const Icon(Icons.payments_outlined),
                    trailing: Icon(
                      paymentMethod == 3
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: paymentMethod == 3 ? AppColors.forest : AppColors.muted,
                    ),
                  ),
                  ListTile(
                    onTap: () => setState(() => paymentMethod = 2),
                    title: const Text('المحفظة الداخلية'),
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    trailing: Icon(
                      paymentMethod == 2
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: paymentMethod == 2 ? AppColors.forest : AppColors.muted,
                    ),
                  ),
                  ListTile(
                    onTap: () => setState(() => paymentMethod = 4),
                    title: const Text('تحويل بنكي'),
                    leading: const Icon(Icons.account_balance_outlined),
                    trailing: Icon(
                      paymentMethod == 4
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: paymentMethod == 4 ? AppColors.forest : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'تفاصيل التكلفة',
              icon: Icons.receipt_long_outlined,
            ),
            AppSurfaceCard(
              child: Column(
                children: [
                  _row('المنتجات', formatPrice(app.subtotal)),
                  const Divider(),
                  _row('الإجمالي', formatPrice(app.subtotal), bold: true),
                  const SizedBox(height: 4),
                  const Text(
                    'سيحسب الخادم الرسوم والخصومات النهائية عند إنشاء الطلب.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _row(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(a, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null)),
            const Spacer(),
            Text(b, style: TextStyle(fontWeight: bold ? FontWeight.w800 : null)),
          ],
        ),
      );
}

class ConnectedAddressFormScreen extends StatefulWidget {
  const ConnectedAddressFormScreen({super.key});

  @override
  State<ConnectedAddressFormScreen> createState() => _ConnectedAddressFormScreenState();
}

class _ConnectedAddressFormScreenState extends State<ConnectedAddressFormScreen> {
  final city = TextEditingController();
  final street = TextEditingController();
  final details = TextEditingController();
  bool isDefault = true;
  bool loading = false;

  @override
  void dispose() {
    city.dispose();
    street.dispose();
    details.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (city.text.trim().isEmpty || street.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل المدينة والشارع.')),
      );
      return;
    }
    setState(() => loading = true);
    try {
      final client = AppScope.of(context).client;
      await client.post('/api/Addresses', body: {
        'city': city.text.trim(),
        'street': street.text.trim(),
        'details': details.text.trim(),
        'isDefault': isDefault,
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : 'تعذر حفظ العنوان.'),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'إضافة عنوان جديد'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: city,
                decoration: const InputDecoration(
                  labelText: 'المدينة',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: street,
                decoration: const InputDecoration(
                  labelText: 'الشارع',
                  prefixIcon: Icon(Icons.route_outlined),
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: details,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'تفاصيل العنوان',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isDefault,
                onChanged: (value) => setState(() => isDefault = value),
                title: const Text('تعيين كعنوان افتراضي'),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: loading ? null : _save,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('حفظ العنوان'),
              ),
            ],
          ),
        ),
      );
}

class _ConnectedOrderSuccessScreen extends StatelessWidget {
  const _ConnectedOrderSuccessScreen({required this.order});
  final CreatedOrder order;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(),
        body: ResultStateView(
          kind: ResultKind.success,
          title: 'تم إنشاء الطلب بنجاح',
          message: 'رقم الطلب #${order.id}',
          primaryLabel: 'عرض طلباتي',
          onPrimary: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/orders',
            (route) => route.isFirst,
          ),
          secondaryLabel: 'العودة للرئيسية',
          onSecondary: () => Navigator.of(context).popUntil((route) => route.isFirst),
          details: AppSurfaceCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('حالة الطلب'),
                  trailing: Text(order.status.isEmpty ? 'تم الإنشاء' : order.status),
                ),
                if (order.total > 0) ...[
                  const Divider(),
                  ListTile(
                    title: const Text('الإجمالي'),
                    trailing: Text(formatPrice(order.total)),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
