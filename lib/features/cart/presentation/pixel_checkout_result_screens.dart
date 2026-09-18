import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

const bool _referenceVisual = bool.fromEnvironment('REFERENCE_VISUAL_TEST');

class PixelOrderSuccessScreen extends StatelessWidget {
  const PixelOrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = _routeArgs(context);
    final app = AppScope.of(context);
    final total = app.subtotal > 0 ? app.subtotal + 10 : null;
    final orderNumber = _value(args, 'orderNumber', fallback: _referenceVisual ? '#MZ-24581' : 'سيظهر بعد إنشاء الطلب');
    final arrival = _value(args, 'arrival', fallback: _referenceVisual ? 'الثلاثاء 17 سبتمبر' : 'حسب موعد التوصيل المختار');
    final totalText = _value(
      args,
      'total',
      fallback: _referenceVisual
          ? '5,240 ر.س'
          : total == null
              ? '—'
              : formatPrice(total),
    );

    return _ResultPage(
      status: _ResultStatus.success,
      appBarTitle: '',
      title: 'تم تأكيد طلبك بنجاح',
      message: 'شكرًا لثقتك بمزرعتي، تم استلام طلبك وسنبدأ بتجهيزه.',
      details: [
        _Detail('رقم الطلب', orderNumber, Icons.receipt_long_outlined),
        _Detail('موعد الوصول', arrival, Icons.local_shipping_outlined),
        _Detail('إجمالي الطلب', totalText, Icons.payments_outlined),
      ],
      primaryLabel: 'تتبع الطلب',
      onPrimary: () => Navigator.pushNamed(context, '/track-order'),
      secondaryLabel: 'عرض تفاصيل الطلب',
      onSecondary: () => Navigator.pushNamed(context, '/order-details'),
      footer: const _EcoFooter(text: 'طلبك محفوظ ويمكنك متابعته من صفحة طلباتي'),
    );
  }
}

class PixelPaymentResultScreen extends StatelessWidget {
  const PixelPaymentResultScreen({super.key, required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final args = _routeArgs(context);
    final app = AppScope.of(context);
    final amount = app.subtotal > 0 ? app.subtotal + 10 : null;

    if (!success) {
      return _ResultPage(
        status: _ResultStatus.error,
        appBarTitle: 'تفاصيل عملية الدفع',
        title: 'تعذر إتمام الدفع',
        message: 'لم يتم خصم المبلغ. تحقق من وسيلة الدفع وحاول مرة أخرى.',
        details: [
          _Detail(
            'رقم الطلب',
            _value(args, 'orderNumber', fallback: _referenceVisual ? '#MZ-24581' : '—'),
            Icons.receipt_long_outlined,
          ),
          _Detail(
            'المبلغ',
            _value(
              args,
              'amount',
              fallback: _referenceVisual
                  ? '5,240 ر.س'
                  : amount == null
                      ? '—'
                      : formatPrice(amount),
            ),
            Icons.payments_outlined,
          ),
          _Detail(
            'سبب الرفض',
            _value(args, 'reason', fallback: 'تعذر إتمام العملية من مزود الدفع'),
            Icons.info_outline_rounded,
          ),
        ],
        primaryLabel: 'إعادة المحاولة',
        onPrimary: () => Navigator.maybePop(context),
        secondaryLabel: 'تغيير طريقة الدفع',
        onSecondary: () => Navigator.pushNamed(context, '/payment-methods'),
        footer: const _EcoFooter(text: 'لن يتم خصم أي مبلغ عند فشل العملية'),
      );
    }

    return _ResultPage(
      status: _ResultStatus.success,
      appBarTitle: 'تفاصيل عملية الدفع',
      title: 'تمت عملية الدفع بنجاح',
      message: 'تم تأكيد العملية وإصدار تفاصيل الدفع بنجاح.',
      details: [
        _Detail(
          'رقم العملية',
          _value(args, 'paymentReference', fallback: _referenceVisual ? '#PAY-874521' : '—'),
          Icons.tag_rounded,
        ),
        _Detail(
          'المبلغ',
          _value(
            args,
            'amount',
            fallback: _referenceVisual
                ? '5,240 ر.س'
                : amount == null
                    ? '—'
                    : formatPrice(amount),
          ),
          Icons.payments_outlined,
        ),
        _Detail(
          'طريقة الدفع',
          _value(args, 'paymentMethod', fallback: _referenceVisual ? 'بطاقة •••• 1098' : 'وسيلة الدفع المختارة'),
          Icons.credit_card_rounded,
        ),
      ],
      primaryLabel: 'تحميل الإيصال',
      onPrimary: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سيتم فتح الإيصال عند توفر رابط الفاتورة من الخادم.')),
      ),
      secondaryLabel: 'التواصل مع الدعم',
      onSecondary: () => Navigator.pushNamed(context, '/support'),
      footer: const _EcoFooter(text: 'يمكنك مراجعة تفاصيل الدفع من طلباتك في أي وقت'),
    );
  }
}

class PixelWalletPendingScreen extends StatelessWidget {
  const PixelWalletPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = _routeArgs(context);
    return _ResultPage(
      status: _ResultStatus.pending,
      appBarTitle: '',
      title: 'طلب الشحن قيد المراجعة',
      message: 'تم استلام طلبك وسنتحقق من التحويل ثم نحدّث رصيد المحفظة.',
      details: [
        _Detail(
          'المبلغ',
          _value(args, 'amount', fallback: _referenceVisual ? '1,000 ر.س' : 'حسب طلب الشحن'),
          Icons.account_balance_wallet_outlined,
        ),
        _Detail(
          'رقم المرجع',
          _value(args, 'reference', fallback: _referenceVisual ? '#TOP-84512' : 'قيد الإنشاء'),
          Icons.tag_rounded,
        ),
        _Detail('الحالة', 'قيد المراجعة', Icons.schedule_rounded),
      ],
      primaryLabel: 'العودة للمحفظة',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(context, '/wallet', (route) => route.isFirst),
      secondaryLabel: 'عرض عمليات المحفظة',
      onSecondary: () => Navigator.pushNamed(context, '/wallet-transactions'),
      footer: const _EcoFooter(text: 'عادةً تتم مراجعة التحويل خلال وقت قصير'),
    );
  }
}

enum _ResultStatus { success, error, pending }

class _ResultPage extends StatelessWidget {
  const _ResultPage({
    required this.status,
    required this.appBarTitle,
    required this.title,
    required this.message,
    required this.details,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.footer,
  });

  final _ResultStatus status;
  final String appBarTitle;
  final String title;
  final String message;
  final List<_Detail> details;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final accent = switch (status) {
      _ResultStatus.success => AppColors.forest,
      _ResultStatus.error => AppColors.terracotta,
      _ResultStatus.pending => AppColors.terracotta,
    };
    final icon = switch (status) {
      _ResultStatus.success => Icons.check_rounded,
      _ResultStatus.error => Icons.priority_high_rounded,
      _ResultStatus.pending => Icons.schedule_rounded,
    };

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: MazraaAppBar(title: appBarTitle),
      body: Stack(
        children: [
          const PositionedDirectional(top: 18, start: -42, child: _CornerSprig(turns: 0.08)),
          const PositionedDirectional(bottom: 0, end: -34, child: _CornerSprig(turns: 0.55)),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _StatusHalo(status: status, icon: icon, accent: accent)),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent,
                      fontSize: 24,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A0D4328), blurRadius: 18, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (var index = 0; index < details.length; index++) ...[
                          _DetailRow(detail: details[index]),
                          if (index != details.length - 1)
                            const Divider(height: 1, color: AppColors.border),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: onPrimary,
                      icon: Icon(status == _ResultStatus.pending ? Icons.account_balance_wallet_outlined : Icons.eco_outlined),
                      label: Text(primaryLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: status == _ResultStatus.error
                          ? OutlinedButton.styleFrom(foregroundColor: AppColors.terracotta, side: const BorderSide(color: AppColors.terracotta))
                          : null,
                      child: Text(secondaryLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  footer,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHalo extends StatelessWidget {
  const _StatusHalo({required this.status, required this.icon, required this.accent});

  final _ResultStatus status;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 182,
        height: 182,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final item in const [
              (0.0, -74.0, 0.08),
              (54.0, -48.0, 0.25),
              (72.0, 2.0, 0.42),
              (48.0, 54.0, 0.62),
              (-50.0, 54.0, -0.62),
              (-72.0, 0.0, -0.42),
              (-54.0, -48.0, -0.25),
            ])
              Transform.translate(
                offset: Offset(item.$1, item.$2),
                child: Transform.rotate(
                  angle: item.$3,
                  child: Icon(
                    Icons.eco_rounded,
                    size: 34,
                    color: status == _ResultStatus.error
                        ? const Color(0xFFEBC7B5)
                        : const Color(0xFF9BB889),
                  ),
                ),
              ),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status == _ResultStatus.error
                    ? AppColors.terracottaSoft
                    : status == _ResultStatus.pending
                        ? const Color(0xFFFFF0DE)
                        : AppColors.forestSoft,
              ),
            ),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
          ],
        ),
      );
}

class _Detail {
  const _Detail(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.detail});
  final _Detail detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
              child: Icon(detail.icon, color: AppColors.forestDark, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(detail.label, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            Flexible(
              child: Text(
                detail.value,
                textAlign: TextAlign.end,
                style: const TextStyle(color: AppColors.forestDark, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
}

class _EcoFooter extends StatelessWidget {
  const _EcoFooter({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco_outlined, color: AppColors.forest, size: 18),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 7),
          const Icon(Icons.eco_outlined, color: AppColors.forest, size: 18),
        ],
      );
}

class _CornerSprig extends StatelessWidget {
  const _CornerSprig({required this.turns});
  final double turns;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: turns * 6.283185307179586,
        child: Opacity(
          opacity: 0.28,
          child: SizedBox(
            width: 118,
            height: 118,
            child: Stack(
              children: const [
                Positioned(left: 50, top: 5, child: Icon(Icons.eco_rounded, color: AppColors.forest, size: 56)),
                Positioned(left: 15, top: 42, child: Icon(Icons.eco_rounded, color: AppColors.terracotta, size: 45)),
                Positioned(left: 62, top: 58, child: Icon(Icons.grass_rounded, color: AppColors.forest, size: 45)),
              ],
            ),
          ),
        ),
      );
}

Map<String, dynamic> _routeArgs(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  if (args is Map<String, dynamic>) return args;
  if (args is Map) return args.map((key, value) => MapEntry(key.toString(), value));
  return const <String, dynamic>{};
}

String _value(Map<String, dynamic> args, String key, {required String fallback}) {
  final value = args[key];
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}
