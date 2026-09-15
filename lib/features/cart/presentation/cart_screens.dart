import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.embedded = false, this.forceEmpty = false});
  final bool embedded;
  final bool forceEmpty;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final lines = forceEmpty ? <CartLine>[] : app.cart;
    final scaffold = Scaffold(
      appBar: MazraaAppBar(
        title: lines.isEmpty ? 'سلة التسوق' : 'سلة التسوق  ${app.cartCount}',
      ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  ),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: Text(
                    'إتمام الشراء • ${formatPrice(app.subtotal + 25)}',
                  ),
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
                              child: Image.asset(
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'أدخل رمز الكوبون',
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم تطبيق الكوبون')),
                            ),
                        child: const Text('تطبيق'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        _cost('المجموع الفرعي', app.subtotal),
                        _cost('الشحن', 25),
                        _cost('الخصم', -15, color: AppColors.terracotta),
                        const Divider(),
                        _cost('الإجمالي', app.subtotal + 10, bold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
    return scaffold;
  }

  static Widget _cost(
    String label,
    double value, {
    bool bold = false,
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: bold ? FontWeight.w700 : null),
        ),
        const Spacer(),
        Text(
          formatPrice(value),
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : null,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool wallet = true;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'إتمام الشراء'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
            ),
            icon: const Icon(Icons.verified_user_outlined),
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
                          child: Image.asset(
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
            SettingsTile(
              icon: Icons.home_rounded,
              title: 'المنزل',
              subtitle: 'الرياض، حي النخيل',
              onTap: () => Navigator.pushNamed(context, '/delivery-slot'),
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
                    onTap: () => setState(() => wallet = true),
                    title: const Text('بطاقة مدى •••• 4821'),
                    leading: const Icon(Icons.credit_card_rounded),
                    trailing: Icon(
                      wallet
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: wallet ? AppColors.forest : AppColors.muted,
                    ),
                  ),
                  ListTile(
                    onTap: () => setState(() => wallet = false),
                    title: const Text('المحفظة الداخلية'),
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    trailing: Icon(
                      !wallet
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: !wallet ? AppColors.forest : AppColors.muted,
                    ),
                  ),
                  SwitchListTile(
                    value: true,
                    onChanged: (_) {},
                    title: const Text('استخدام رصيد المحفظة'),
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
                  _row('الشحن', '25 ر.س'),
                  _row('الخصم', '-15 ر.س'),
                  const Divider(),
                  _row(
                    'الإجمالي النهائي',
                    formatPrice(app.subtotal + 10),
                    bold: true,
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

class DeliverySlotScreen extends StatefulWidget {
  const DeliverySlotScreen({super.key});
  @override
  State<DeliverySlotScreen> createState() => _DeliverySlotScreenState();
}

class _DeliverySlotScreenState extends State<DeliverySlotScreen> {
  int day = 0;
  int slot = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'موعد التوصيل'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر موعد التوصيل',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
          ),
          const SizedBox(height: 14),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('اليوم')),
              ButtonSegment(value: 1, label: Text('غدًا')),
              ButtonSegment(value: 2, label: Text('الثلاثاء 17')),
            ],
            selected: {day},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => day = v.first),
          ),
          const SizedBox(height: 16),
          ...['9 ص - 12 م', '12 م - 3 م', '3 م - 6 م'].asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppSurfaceCard(
                color: slot == e.key ? AppColors.forestSoft : null,
                child: ListTile(
                  onTap: () => setState(() => slot = e.key),
                  title: Text(e.value),
                  leading: const Icon(Icons.schedule_rounded),
                  trailing: Icon(
                    slot == e.key
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: slot == e.key ? AppColors.forest : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
          const AppSurfaceCard(
            color: AppColors.terracottaSoft,
            child: ListTile(
              leading: Icon(
                Icons.local_shipping_rounded,
                color: AppColors.terracotta,
              ),
              title: Text('رسوم التوصيل'),
              trailing: Text('25 ر.س'),
            ),
          ),
          const SizedBox(height: 10),
          const SettingsTile(
            icon: Icons.location_on_rounded,
            title: 'عنوان التوصيل',
            subtitle: 'الرياض، حي النخيل',
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تأكيد الموعد'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/delivery-preferences'),
            child: const Text('تفضيلات التوصيل'),
          ),
        ],
      ),
    ),
  );
}

class DeliveryPreferencesScreen extends StatefulWidget {
  const DeliveryPreferencesScreen({super.key});
  @override
  State<DeliveryPreferencesScreen> createState() =>
      _DeliveryPreferencesScreenState();
}

class _DeliveryPreferencesScreenState extends State<DeliveryPreferencesScreen> {
  bool contactless = true;
  bool call = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تفضيلات التوصيل'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: _DeliveryChoice(
                  icon: Icons.local_shipping_rounded,
                  label: 'توصيل للعنوان',
                  selected: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _DeliveryChoice(
                  icon: Icons.location_on_outlined,
                  label: 'استلام من نقطة',
                  selected: false,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _DeliveryChoice(
                  icon: Icons.storefront_outlined,
                  label: 'استلام من المزرعة',
                  selected: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: contactless,
            onChanged: (v) => setState(() => contactless = v),
            title: const Text('توصيل بدون تلامس'),
            subtitle: const Text('اترك الطلب عند الباب'),
            secondary: const Icon(Icons.back_hand_outlined),
          ),
          SwitchListTile(
            value: call,
            onChanged: (v) => setState(() => call = v),
            title: const Text('الاتصال قبل التوصيل'),
            secondary: const Icon(Icons.phone_in_talk_outlined),
          ),
          const SizedBox(height: 10),
          const TextField(
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'تعليمات للموصل',
              hintText: 'مثال: اترك الطلب عند البوابة...',
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ التفضيلات'),
          ),
        ],
      ),
    ),
  );
}

class _DeliveryChoice extends StatelessWidget {
  const _DeliveryChoice({
    required this.icon,
    required this.label,
    required this.selected,
  });
  final IconData icon;
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    color: selected ? AppColors.forestSoft : null,
    child: Column(
      children: [
        Icon(
          icon,
          size: 34,
          color: selected ? AppColors.forest : AppColors.muted,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.forest : AppColors.muted,
        ),
      ],
    ),
  );
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'طرق الدفع'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'بطاقاتك المحفوظة',
            icon: Icons.credit_card_rounded,
          ),
          const _PaymentTile(
            title: 'بطاقة فيزا',
            subtitle: '•••• 4821',
            icon: Icons.credit_card_rounded,
            selected: true,
          ),
          const SizedBox(height: 8),
          const _PaymentTile(
            title: 'بطاقة مدى',
            subtitle: '•••• 1098',
            icon: Icons.credit_card_rounded,
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'خيارات الدفع الأخرى',
            icon: Icons.payments_outlined,
          ),
          _PaymentTile(
            title: 'الدفع عند الاستلام',
            subtitle: 'ادفع عند استلام طلبك',
            icon: Icons.payments_outlined,
            onTap: () => Navigator.pushNamed(context, '/cash-on-delivery'),
          ),
          const SizedBox(height: 8),
          _PaymentTile(
            title: 'التحويل البنكي',
            subtitle: 'حوّل وأرفق إيصال البنك',
            icon: Icons.account_balance_outlined,
            onTap: () => Navigator.pushNamed(context, '/bank-transfer'),
          ),
          const SizedBox(height: 8),
          const _PaymentTile(
            title: 'المحفظة الداخلية',
            subtitle: 'استخدم رصيد المحفظة',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add-card'),
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('إضافة بطاقة جديدة'),
          ),
        ],
      ),
    ),
  );
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.selected = false,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    color: selected ? AppColors.forestSoft : null,
    child: ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: selected ? AppColors.forest : AppColors.terracotta,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.forest : AppColors.muted,
      ),
    ),
  );
}

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'إضافة بطاقة جديدة'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.forestDark, AppColors.forest],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppLogo(size: 40),
                Spacer(),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '1234   5678   9012   3456',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text('مزرعتي', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'اسم حامل البطاقة',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'رقم البطاقة',
              prefixIcon: Icon(Icons.credit_card_rounded),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'تاريخ الانتهاء'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'رمز CVV'),
                ),
              ),
            ],
          ),
          CheckboxListTile(
            value: true,
            onChanged: (_) {},
            contentPadding: EdgeInsets.zero,
            title: const Text('حفظ البطاقة للشراء لاحقًا'),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ البطاقة'),
          ),
        ],
      ),
    ),
  );
}

class CashOnDeliveryScreen extends StatelessWidget {
  const CashOnDeliveryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 92,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_rounded, size: 48, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'الدفع عند الاستلام',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Text('مبلغ الطلب'),
                      Text(
                        '85 ر.س',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Text('رسوم التوصيل'),
                      Text(
                        '25 ر.س',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Text('المجموع'),
                      Text(
                        '110 ر.س',
                        style: TextStyle(
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const AppSurfaceCard(
            child: ListTile(
              leading: Icon(
                Icons.radio_button_checked,
                color: AppColors.forest,
              ),
              title: Text('الدفع عند الاستلام'),
              subtitle: Text('ادفع نقدًا عند وصول الطلب'),
            ),
          ),
          const SizedBox(height: 10),
          const AppSurfaceCard(
            color: AppColors.terracottaSoft,
            child: ListTile(
              leading: Icon(
                Icons.info_outline_rounded,
                color: AppColors.terracotta,
              ),
              title: Text('يرجى تجهيز المبلغ عند الاستلام'),
            ),
          ),
          const SizedBox(height: 10),
          const SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'عنوان التوصيل',
            subtitle: 'الرياض، حي النخيل',
          ),
          const SizedBox(height: 26),
          FilledButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
            ),
            child: const Text('تأكيد الدفع عند الاستلام'),
          ),
        ],
      ),
    ),
  );
}

class BankTransferScreen extends StatelessWidget {
  const BankTransferScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'التحويل البنكي'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'مبلغ الشحن',
              hintText: 'أدخل المبلغ بالريال',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
          ),
          const SizedBox(height: 14),
          const AppSurfaceCard(
            color: AppColors.forest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بنك المزرعة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Divider(color: Colors.white24),
                Text(
                  'اسم البنك: بنك المزرعة',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'اسم المستفيد: شركة مزرعتي',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'رقم الآيبان: SA00 0000 0000 0000 0000',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 46,
                  color: AppColors.forest,
                ),
                Text('أرفق إيصال التحويل'),
                Text('PNG أو JPG', style: TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AppSurfaceCard(
            color: AppColors.terracottaSoft,
            child: ListTile(
              leading: Icon(
                Icons.schedule_rounded,
                color: AppColors.terracotta,
              ),
              title: Text('يستغرق التحقق حتى 24 ساعة'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WalletPendingScreen()),
            ),
            icon: const Icon(Icons.send_rounded),
            label: const Text('إرسال طلب الشحن'),
          ),
        ],
      ),
    ),
  );
}

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: ResultStateView(
      kind: ResultKind.success,
      title: 'تم تأكيد طلبك بنجاح',
      message: 'شكرًا لثقتك بمزرعتي',
      primaryLabel: 'تتبع الطلب',
      onPrimary: () => Navigator.pushNamed(context, '/track-order'),
      secondaryLabel: 'عرض تفاصيل الطلب',
      onSecondary: () => Navigator.pushNamed(context, '/order-details'),
      details: const AppSurfaceCard(
        child: Column(
          children: [
            ListTile(title: Text('رقم الطلب'), trailing: Text('#MZ-24581')),
            Divider(),
            ListTile(
              title: Text('موعد الوصول'),
              trailing: Text('الثلاثاء 17 سبتمبر'),
            ),
            Divider(),
            ListTile(title: Text('إجمالي الطلب'), trailing: Text('5,240 ر.س')),
          ],
        ),
      ),
    ),
  );
}

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key, this.success = true});
  final bool success;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تفاصيل عملية الدفع'),
    body: ResultStateView(
      kind: success ? ResultKind.success : ResultKind.error,
      title: success ? 'تمت العملية بنجاح' : 'تعذر إتمام الدفع',
      message: success
          ? 'شكرًا لك، تم السداد وإصدار إيصال العملية.'
          : 'لم يتم خصم المبلغ. تحقق من البنك وحاول مرة أخرى.',
      primaryLabel: success ? 'تحميل الإيصال' : 'إعادة المحاولة',
      onPrimary: () => Navigator.pop(context),
      secondaryLabel: success ? 'التواصل مع الدعم' : 'تغيير طريقة الدفع',
      onSecondary: () => Navigator.pushNamed(context, '/payment-methods'),
      details: const AppSurfaceCard(
        child: Column(
          children: [
            ListTile(title: Text('رقم العملية'), trailing: Text('#PAY-874521')),
            Divider(),
            ListTile(title: Text('المبلغ'), trailing: Text('5,240 ر.س')),
            Divider(),
            ListTile(title: Text('بطاقة الدفع'), trailing: Text('•••• 1098')),
          ],
        ),
      ),
    ),
  );
}

class WalletPendingScreen extends StatelessWidget {
  const WalletPendingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: MazraaAppBar(),
    body: ResultStateView(
      kind: ResultKind.pending,
      title: 'طلب الشحن قيد المراجعة',
      message: 'تم استلام طلبك، وسنتحقق من عملية التحويل قريبًا.',
      primaryLabel: 'العودة للمحفظة',
      secondaryLabel: 'عرض التفاصيل',
    ),
  );
}
