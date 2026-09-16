import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class MatchedOrderDetailsScreen extends StatelessWidget {
  const MatchedOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ReferenceDemoData.products.take(2).toList();
    return _BaseScreen(
      title: 'تفاصيل الطلب',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _orderHeader('MZ-24581', 'قيد التوصيل', AppColors.terracotta),
          const SizedBox(height: 12),
          _stepper(const ['تم الطلب', 'تم التأكيد', 'قيد التجهيز', 'خرج للتوصيل'], 3),
          const SizedBox(height: 14),
          _sectionCard('المنتجات', Icons.shopping_bag_outlined, Column(children: products.map(_orderProduct).toList())),
          const SizedBox(height: 12),
          _sectionCard('عنوان التوصيل', Icons.location_on_outlined, const Text('الرياض، حي النخيل، شارع الأمير محمد بن سلمان')),
          const SizedBox(height: 12),
          _sectionCard(
            'ملخص الدفع',
            Icons.receipt_long_outlined,
            const Column(children: [
              _StaticRow('المجموع الفرعي', '520 ر.س'),
              _StaticRow('التوصيل', '25 ر.س'),
              _StaticRow('الخصم', '-20 ر.س'),
              Divider(),
              _StaticRow('الإجمالي', '525 ر.س', bold: true),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/invoice'), child: const Text('عرض الفاتورة'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: () => Navigator.pushNamed(context, '/track-order'), child: const Text('تتبع الطلب'))),
          ]),
        ],
      ),
    );
  }
}

class MatchedTrackOrderScreen extends StatelessWidget {
  const MatchedTrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تتبع الطلب',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 290,
              decoration: BoxDecoration(color: const Color(0xFFE6EFDD), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Stack(children: [
                Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                const Positioned(top: 52, right: 86, child: Icon(Icons.location_on_rounded, size: 42, color: AppColors.terracotta)),
                const Positioned(bottom: 55, left: 82, child: Icon(Icons.home_rounded, size: 36, color: AppColors.forestDark)),
                Positioned(top: 135, left: 150, child: Container(width: 54, height: 54, decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle), child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 30))),
              ]),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              'الموصل في الطريق إليك',
              Icons.delivery_dining_rounded,
              Row(children: [
                const CircleAvatar(radius: 28, backgroundColor: AppColors.forestSoft, child: Icon(Icons.person_rounded, color: AppColors.forestDark)),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('أحمد محمد', style: TextStyle(fontWeight: FontWeight.w900)), Text('يصل خلال 15 - 20 دقيقة', style: TextStyle(color: AppColors.muted))])),
                IconButton(onPressed: () {}, icon: const Icon(Icons.phone_rounded, color: AppColors.forest)),
              ]),
            ),
            const SizedBox(height: 12),
            _sectionCard('حالة الطلب', Icons.route_rounded, _stepper(const ['تم الطلب', 'تم التجهيز', 'استلمه الموصل', 'قريب منك'], 2)),
          ],
        ),
      );
}

class MatchedCancelOrderScreen extends StatefulWidget {
  const MatchedCancelOrderScreen({super.key});

  @override
  State<MatchedCancelOrderScreen> createState() => _MatchedCancelOrderScreenState();
}

class _MatchedCancelOrderScreenState extends State<MatchedCancelOrderScreen> {
  int reason = 0;

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'إلغاء الطلب',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Icon(Icons.delete_outline_rounded, size: 68, color: AppColors.terracotta)),
            const SizedBox(height: 8),
            const Text('هل تريد إلغاء هذا الطلب؟', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            _sectionCard(
              'الطلب MZ-24581',
              Icons.shopping_bag_outlined,
              Row(children: ReferenceDemoData.products.take(3).map((p) => Expanded(child: Padding(padding: const EdgeInsets.all(4), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 76, child: AppDataImage(p.image, fit: BoxFit.cover)))))).toList()),
            ),
            const SizedBox(height: 12),
            const Text('اختر سبب الإلغاء', style: TextStyle(fontWeight: FontWeight.w900)),
            ...['غيرت رأيي', 'وجدت سعرًا أفضل', 'تأخر موعد التوصيل', 'أريد تعديل الطلب'].asMap().entries.map(
              (entry) => RadioListTile<int>(
                value: entry.key,
                groupValue: reason,
                onChanged: (value) => setState(() => reason = value ?? 0),
                title: Text(entry.value),
              ),
            ),
            TextField(maxLines: 3, decoration: InputDecoration(hintText: 'ملاحظات إضافية', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
                onPressed: () => Navigator.pushReplacementNamed(context, '/order-cancelled'),
                child: const Text('إلغاء الطلب'),
              ),
            ),
          ],
        ),
      );
}

class MatchedOrderCancelledScreen extends StatelessWidget {
  const MatchedOrderCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تم إلغاء الطلب',
        child: _CenteredState(
          icon: Icons.check_circle_rounded,
          title: 'تم إلغاء الطلب بنجاح',
          message: 'الطلب رقم MZ-24581 تم إلغاؤه. سيتم إعادة المبلغ إلى وسيلة الدفع المستخدمة.',
          action: 'العودة إلى طلباتي',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => r.isFirst),
        ),
      );
}

class MatchedRateOrderScreen extends StatefulWidget {
  const MatchedRateOrderScreen({super.key});

  @override
  State<MatchedRateOrderScreen> createState() => _MatchedRateOrderScreenState();
}

class _MatchedRateOrderScreenState extends State<MatchedRateOrderScreen> {
  int orderRating = 5;
  int deliveryRating = 5;

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تقييم الطلب',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionCard(
              'كيف كانت تجربتك؟',
              Icons.star_rounded,
              Column(children: [
                _ratingRow('الطلب', orderRating, (v) => setState(() => orderRating = v)),
                const SizedBox(height: 12),
                _ratingRow('التوصيل', deliveryRating, (v) => setState(() => deliveryRating = v)),
              ]),
            ),
            const SizedBox(height: 12),
            ...ReferenceDemoData.products.take(2).map((p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _sectionCard(p.name, Icons.shopping_bag_outlined, _ratingRow('تقييم المنتج', 5, (_) {})))),
            TextField(maxLines: 4, decoration: InputDecoration(hintText: 'شاركنا ملاحظاتك', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 12),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('إرسال التقييم'))),
          ],
        ),
      );
}

class MatchedInvoiceScreen extends StatelessWidget {
  const MatchedInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'الفاتورة الإلكترونية',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: const Column(children: [
                AppLogo(size: 62, showName: true),
                SizedBox(height: 10),
                Text('فاتورة ضريبية', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.forestDark)),
                Text('رقم الطلب: MZ-24581'),
                Text('16 سبتمبر 2026'),
              ]),
            ),
            const SizedBox(height: 12),
            _sectionCard('تفاصيل المنتجات', Icons.receipt_long_outlined, Column(children: ReferenceDemoData.products.take(2).map(_orderProduct).toList())),
            const SizedBox(height: 12),
            _sectionCard(
              'الإجمالي',
              Icons.account_balance_wallet_outlined,
              const Column(children: [
                _StaticRow('قيمة المنتجات', '520 ر.س'),
                _StaticRow('الضريبة', '78 ر.س'),
                _StaticRow('الشحن', '25 ر.س'),
                Divider(),
                _StaticRow('الإجمالي شامل الضريبة', '623 ر.س', bold: true),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 52, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('تنزيل الفاتورة'))),
          ],
        ),
      );
}

class MatchedReturnsScreen extends StatelessWidget {
  const MatchedReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'المرتجعات والاسترداد',
        child: Column(
          children: [
            _returnCard(context, ReferenceDemoData.products.first, 'طلب إرجاع قيد المراجعة', 'RT-10342', AppColors.terracotta),
            const SizedBox(height: 10),
            _returnCard(context, ReferenceDemoData.products[1], 'تم الاسترداد', 'RT-10296', AppColors.forest),
          ],
        ),
      );
}

class MatchedReturnRequestScreen extends StatelessWidget {
  const MatchedReturnRequestScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'طلب إرجاع',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionCard('المنتج', Icons.shopping_bag_outlined, _orderProduct(ReferenceDemoData.products.first)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: 'المنتج غير مطابق',
              items: const [
                DropdownMenuItem(value: 'المنتج غير مطابق', child: Text('المنتج غير مطابق')),
                DropdownMenuItem(value: 'تالف', child: Text('المنتج تالف')),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: 'سبب الإرجاع'),
            ),
            const SizedBox(height: 10),
            TextField(maxLines: 4, decoration: InputDecoration(labelText: 'تفاصيل إضافية', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 10),
            _sectionCard(
              'طريقة الاسترداد',
              Icons.account_balance_wallet_outlined,
              const Column(children: [
                ListTile(leading: Icon(Icons.radio_button_checked_rounded, color: AppColors.forest), title: Text('المحفظة')),
                ListTile(leading: Icon(Icons.radio_button_unchecked_rounded), title: Text('وسيلة الدفع الأصلية')),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pushReplacementNamed(context, '/return-success'), child: const Text('إرسال طلب الإرجاع'))),
          ],
        ),
      );
}

class MatchedReturnSuccessScreen extends StatelessWidget {
  const MatchedReturnSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'المرتجعات والاسترداد',
        child: _CenteredState(
          icon: Icons.check_circle_rounded,
          title: 'تم إرسال طلب الإرجاع',
          message: 'رقم الطلب RT-10342. سنراجع الطلب ونرسل لك تحديثًا عند تغيير حالته.',
          action: 'عرض حالة الإرجاع',
          onPressed: () => Navigator.pushReplacementNamed(context, '/refund-status'),
        ),
      );
}

class MatchedRefundStatusScreen extends StatelessWidget {
  const MatchedRefundStatusScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'حالة الاسترداد',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _orderHeader('RT-10342', 'قيد المعالجة', AppColors.terracotta),
          const SizedBox(height: 14),
          _sectionCard('تقدم الطلب', Icons.timeline_rounded, _stepper(const ['تم استلام الطلب', 'تمت الموافقة', 'استلام المنتج', 'إعادة المبلغ'], 1)),
          const SizedBox(height: 12),
          _sectionCard('بيانات الاسترداد', Icons.account_balance_wallet_outlined, const Column(children: [
            _StaticRow('قيمة الاسترداد', '120 ر.س'),
            _StaticRow('الطريقة', 'المحفظة'),
            _StaticRow('المدة المتوقعة', '2 - 5 أيام عمل'),
          ])),
        ]),
      );
}

class _BaseScreen extends StatelessWidget {
  const _BaseScreen({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: MazraaAppBar(title: title),
        body: BotanicalBackdrop(
          dense: true,
          child: AppPage(padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 28), child: child),
        ),
      );
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.icon, required this.title, required this.message, required this.action, required this.onPressed});
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 150, height: 150, decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle), child: Icon(icon, size: 76, color: AppColors.forest)),
            const SizedBox(height: 22),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: onPressed, child: Text(action))),
          ]),
        ),
      );
}

class _StaticRow extends StatelessWidget {
  const _StaticRow(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: bold ? AppColors.forest : AppColors.forestDark, fontWeight: bold ? FontWeight.w900 : FontWeight.w700)),
        ]),
      );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .72)..strokeWidth = 6;
    for (double y = 35; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 12), paint);
    }
    for (double x = 28; x < size.width; x += 68) {
      canvas.drawLine(Offset(x, 0), Offset(x + 18, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _sectionCard(String title, IconData icon, Widget child) => Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Icon(icon, color: AppColors.forestDark), const SizedBox(width: 7), Text(title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 15))]),
        const SizedBox(height: 11),
        child,
      ]),
    );

Widget _orderHeader(String id, String status, Color statusColor) => Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(children: [
        const Icon(Icons.shopping_bag_outlined, color: AppColors.forestDark),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الطلب $id', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.forestDark)), const Text('16 سبتمبر 2026', style: TextStyle(color: AppColors.muted, fontSize: 11))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11))),
      ]),
    );

Widget _stepper(List<String> steps, int active) => Column(
      children: List.generate(
        steps.length,
        (index) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            CircleAvatar(radius: 13, backgroundColor: index <= active ? AppColors.forest : AppColors.border, child: Icon(index < active ? Icons.check_rounded : Icons.circle, color: Colors.white, size: 13)),
            if (index < steps.length - 1) Container(width: 2, height: 34, color: index < active ? AppColors.forest : AppColors.border),
          ]),
          const SizedBox(width: 9),
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(steps[index], style: TextStyle(fontWeight: index == active ? FontWeight.w900 : FontWeight.w600, color: AppColors.forestDark))),
        ]),
      ),
    );

Widget _orderProduct(dynamic product) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 72, height: 62, child: AppDataImage(product.image, fit: BoxFit.cover))),
        const SizedBox(width: 9),
        Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800))),
        Text(formatPrice(product.price), style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900)),
      ]),
    );

Widget _ratingRow(String label, int value, ValueChanged<int> onChanged) => Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
      ...List.generate(5, (index) => IconButton(onPressed: () => onChanged(index + 1), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 35, minHeight: 35), icon: Icon(index < value ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.warning))),
    ]);

Widget _returnCard(BuildContext context, dynamic product, String status, String id, Color color) => Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(children: [
        Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(11), child: SizedBox(width: 92, height: 78, child: AppDataImage(product.image, fit: BoxFit.cover))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text(id, style: const TextStyle(color: AppColors.muted, fontSize: 11)), const SizedBox(height: 5), Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900))])),
        ]),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/refund-status'), child: const Text('عرض التفاصيل'))),
      ]),
    );

BoxDecoration _cardDecoration() => BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Color(0x090D4328), blurRadius: 10, offset: Offset(0, 3))]);
