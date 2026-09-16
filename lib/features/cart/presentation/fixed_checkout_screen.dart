import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class FixedCheckoutScreen extends StatefulWidget {
  const FixedCheckoutScreen({super.key});

  @override
  State<FixedCheckoutScreen> createState() => _FixedCheckoutScreenState();
}

class _FixedCheckoutScreenState extends State<FixedCheckoutScreen> {
  bool useWallet = true;
  int payment = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final lines = app.cart.isEmpty ? ReferenceDemoData.cart : app.cart;
    final subtotal = lines.fold<double>(
      0,
      (sum, line) => sum + line.product.price * line.quantity,
    );
    const shipping = 25.0;
    final discount = subtotal > 500 ? 50.0 : 0.0;
    final total = subtotal + shipping - discount;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: const MazraaAppBar(title: 'إتمام الشراء'),
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _section(
              title: 'ملخص الطلب',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: lines
                    .take(2)
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: SizedBox(
                                width: 82,
                                height: 72,
                                child: AppDataImage(
                                  line.product.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.forestDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${line.quantity} ×',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatPrice(line.product.price * line.quantity),
                              style: const TextStyle(
                                color: AppColors.forest,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'عنوان التوصيل',
              icon: Icons.location_on_outlined,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/addresses'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.forestSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.forest),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الرياض، حي النخيل',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: AppColors.forestDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'طريقة الدفع',
              icon: Icons.credit_card_rounded,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _paymentOption(
                          0,
                          'بطاقة بنكية',
                          '**** 4821',
                          Icons.credit_card_rounded,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _paymentOption(
                          1,
                          'المحفظة',
                          'الرصيد المتاح',
                          Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ivory,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.forestDark,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'استخدام رصيد المحفظة',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Switch(
                            value: useWallet,
                            onChanged: (value) =>
                                setState(() => useWallet = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'تفاصيل التكلفة',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _costRow('المنتجات', subtotal),
                  _costRow('الشحن', shipping),
                  _costRow(
                    'الخصم',
                    -discount,
                    color: AppColors.terracotta,
                  ),
                  const Divider(height: 24),
                  _costRow('الإجمالي النهائي', total, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/order-success'),
                icon: const Icon(Icons.eco_outlined),
                label: const Text(
                  'تأكيد الطلب',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.forestDark,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'دفع آمن',
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(
    int value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final selected = payment == value;
    return InkWell(
      onTap: () => setState(() => payment = value),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: selected ? AppColors.forestSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.forestDark),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 9,
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
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _section({
  required String title,
  required IconData icon,
  required Widget child,
}) =>
    Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0D4328),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.forestDark, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );

Widget _costRow(
  String label,
  double value, {
  bool bold = false,
  Color? color,
}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
              color: bold ? AppColors.forestDark : null,
            ),
          ),
          const Spacer(),
          Text(
            formatPrice(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: color ??
                  (bold ? AppColors.forest : AppColors.forestDark),
            ),
          ),
        ],
      ),
    );
