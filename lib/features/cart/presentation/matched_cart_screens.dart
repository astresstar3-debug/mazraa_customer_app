import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

class MatchedCartScreen extends StatelessWidget {
  const MatchedCartScreen({super.key, this.forceEmpty = false});

  final bool forceEmpty;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final source = app.cart.isEmpty ? ReferenceDemoData.cart : app.cart;
    final lines = forceEmpty ? <CartLine>[] : source;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 72,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark),
                  ),
                  const Spacer(),
                  const AppLogo(size: 48),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: lines.isEmpty ? const _MatchedEmptyCartBody() : _MatchedFilledCart(lines: lines),
    );
  }
}

class _MatchedFilledCart extends StatelessWidget {
  const _MatchedFilledCart({required this.lines});
  final List<CartLine> lines;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final subtotal = lines.fold<double>(
      0,
      (sum, line) => sum + (line.product.price * line.quantity),
    );
    const shipping = 25.0;
    const discount = 0.0;
    final total = subtotal + shipping - discount;

    return AppPage(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'سلة التسوق',
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 9),
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.terracotta,
                child: Text(
                  '${lines.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MatchedCartLine(
                line: line,
                onQuantityChanged: (value) => app.setQuantity(line.product, value),
                onDelete: () => app.setQuantity(line.product, 0),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, color: AppColors.forestDark),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'أدخل رمز الكوبون',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _summaryRow('المجموع الفرعي', subtotal, Icons.shopping_cart_outlined),
                _summaryRow('الشحن', shipping, Icons.local_shipping_outlined),
                _summaryRow('الخصم', discount, Icons.local_offer_outlined),
                const Divider(height: 24),
                _summaryRow('الإجمالي', total, Icons.account_balance_wallet_outlined, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('إتمام الشراء', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchedCartLine extends StatelessWidget {
  const _MatchedCartLine({
    required this.line,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  final CartLine line;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        height: 118,
        padding: const EdgeInsets.all(9),
        decoration: _cardDecoration(),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 112,
                height: 100,
                child: AppDataImage(line.product.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatPrice(line.product.price),
                    style: const TextStyle(
                      color: AppColors.terracotta,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _qtyButton(Icons.remove_rounded, () => onQuantityChanged(line.quantity > 1 ? line.quantity - 1 : 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                      _qtyButton(Icons.add_rounded, () => onQuantityChanged(line.quantity + 1)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.terracotta),
            ),
          ],
        ),
      );

  Widget _qtyButton(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: AppColors.forestDark),
        ),
      );
}

class _MatchedEmptyCartBody extends StatelessWidget {
  const _MatchedEmptyCartBody();

  @override
  Widget build(BuildContext context) => BotanicalBackdrop(
        dense: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'سلة التسوق',
                  style: TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 44),
                Container(
                  width: 210,
                  height: 210,
                  decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 118, color: AppColors.terracotta),
                      Positioned(top: 27, right: 28, child: Icon(Icons.wb_sunny_outlined, color: AppColors.terracotta, size: 38)),
                      Positioned(bottom: 28, left: 30, child: Icon(Icons.eco_rounded, color: AppColors.forest, size: 44)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'سلتك فارغة',
                  style: TextStyle(color: AppColors.forestDark, fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                const Text(
                  'أضف منتجاتك المفضلة وابدأ التسوق',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 15),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/products'),
                    icon: const Icon(Icons.eco_outlined),
                    label: const Text('تصفح المنتجات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/offers'),
                    icon: const Icon(Icons.local_offer_outlined, color: AppColors.terracotta),
                    label: const Text('اكتشف العروض', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class MatchedCheckoutScreen extends StatefulWidget {
  const MatchedCheckoutScreen({super.key});

  @override
  State<MatchedCheckoutScreen> createState() => _MatchedCheckoutScreenState();
}

class _MatchedCheckoutScreenState extends State<MatchedCheckoutScreen> {
  bool useWallet = true;
  int payment = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final lines = app.cart.isEmpty ? ReferenceDemoData.cart : app.cart;
    final subtotal = lines.fold<double>(0, (sum, line) => sum + line.product.price * line.quantity);
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
            _checkoutSection(
              title: 'ملخص الطلب',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: lines.take(2).map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: SizedBox(width: 82, height: 72, child: AppDataImage(line.product.image, fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(line.product.name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.forestDark)),
                            const SizedBox(height: 4),
                            Text('${line.quantity} ×', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(formatPrice(line.product.price * line.quantity), style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w900)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _checkoutSection(
              title: 'عنوان التوصيل',
              icon: Icons.location_on_outlined,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/addresses'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.forest),
                      SizedBox(width: 8),
                      Expanded(child: Text('الرياض، حي النخيل', style: TextStyle(fontWeight: FontWeight.w800))),
                      Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.forestDark),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _checkoutSection(
              title: 'طريقة الدفع',
              icon: Icons.credit_card_rounded,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _paymentOption(0, 'بطاقة بنكية', '**** 4821', Icons.credit_card_rounded)),
                      const SizedBox(width: 9),
                      Expanded(child: _paymentOption(1, 'المحفظة', 'الرصيد المتاح', Icons.account_balance_wallet_outlined)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: useWallet,
                    onChanged: (value) => setState(() => useWallet = value),
                    secondary: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.forestDark),
                    title: const Text('استخدام رصيد المحفظة', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _checkoutSection(
              title: 'تفاصيل التكلفة',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _costRow('المنتجات', subtotal),
                  _costRow('الشحن', shipping),
                  _costRow('الخصم', -discount, color: AppColors.terracotta),
                  const Divider(height: 24),
                  _costRow('الإجمالي النهائي', total, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/order-success'),
                icon: const Icon(Icons.eco_outlined),
                label: const Text('تأكيد الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: AppColors.forestDark, size: 18),
                SizedBox(width: 6),
                Text('دفع آمن', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(int value, String title, String subtitle, IconData icon) {
    final selected = payment == value;
    return InkWell(
      onTap: () => setState(() => payment = value),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: selected ? AppColors.forestSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? AppColors.forest : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.forestDark),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 9)),
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: selected ? AppColors.forest : AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

Widget _checkoutSection({required String title, required IconData icon, required Widget child}) => Container(
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.forestDark, size: 20),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );

Widget _costRow(String label, double value, {bool bold = false, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w500, color: bold ? AppColors.forestDark : null)),
          const Spacer(),
          Text(formatPrice(value), style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w700, color: color ?? (bold ? AppColors.forest : AppColors.forestDark))),
        ],
      ),
    );

Widget _summaryRow(String label, double value, IconData icon, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.forestDark, size: 19),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(color: AppColors.forestDark, fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
          const Spacer(),
          Text(formatPrice(value), style: TextStyle(color: value < 0 ? AppColors.terracotta : AppColors.terracotta, fontSize: bold ? 18 : 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(color: Color(0x0A0D4328), blurRadius: 12, offset: Offset(0, 3)),
      ],
    );
