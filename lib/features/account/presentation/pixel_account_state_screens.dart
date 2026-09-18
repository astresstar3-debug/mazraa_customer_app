import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

const bool _referenceVisual = bool.fromEnvironment('REFERENCE_VISUAL_TEST');

class PixelEmptyAddressesScreen extends StatelessWidget {
  const PixelEmptyAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) => _IllustratedStatePage(
        appBarTitle: 'العناوين',
        illustration: const _AddressIllustration(),
        title: 'لم تضف أي عنوان بعد',
        message: 'أضف عنوانك لتسهيل التوصيل واستلام الطلبات بسرعة.',
        primaryLabel: 'إضافة عنوان جديد',
        onPrimary: () => Navigator.pushNamed(context, '/add-address'),
        secondaryLabel: 'العودة للحساب',
        onSecondary: () => Navigator.maybePop(context),
      );
}

class PixelOfflineScreen extends StatelessWidget {
  const PixelOfflineScreen({super.key});

  @override
  Widget build(BuildContext context) => _IllustratedStatePage(
        appBarTitle: '',
        illustration: const _OfflineIllustration(),
        title: 'لا يوجد اتصال بالإنترنت',
        message: 'تحقق من اتصالك بالشبكة ثم حاول مرة أخرى.',
        primaryLabel: 'إعادة المحاولة',
        onPrimary: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
        secondaryLabel: 'فتح الإعدادات',
        onSecondary: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يمكنك فتح إعدادات الشبكة من إعدادات جهازك.')),
        ),
      );
}

class PixelOrderCancelledScreen extends StatelessWidget {
  const PixelOrderCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).orders;
    final order = orders.isEmpty ? null : orders.first;
    return _IllustratedStatePage(
      appBarTitle: 'إلغاء الطلب',
      illustration: const _SuccessWreath(icon: Icons.check_rounded),
      title: 'تم إلغاء الطلب بنجاح',
      message: 'تم تحديث حالة طلبك، وسيتم التعامل مع الاسترداد وفق طريقة الدفع.',
      details: [
        _StateDetail('رقم الطلب', order == null ? (_referenceVisual ? '#MZ-24581' : '—') : '#${order.id}', Icons.receipt_long_outlined),
        _StateDetail('حالة الطلب', 'ملغي', Icons.cancel_outlined),
        _StateDetail(
          'إجمالي الطلب',
          order == null ? (_referenceVisual ? '5,240 ر.س' : '—') : formatPrice(order.total),
          Icons.payments_outlined,
        ),
      ],
      primaryLabel: 'العودة إلى طلباتي',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => route.isFirst),
      secondaryLabel: 'العودة للرئيسية',
      onSecondary: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => route.isFirst),
    );
  }
}

class PixelReturnSuccessScreen extends StatelessWidget {
  const PixelReturnSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = _args(context);
    return _IllustratedStatePage(
      appBarTitle: 'المرتجعات والاسترداد',
      illustration: const _ReturnIllustration(),
      title: 'تم إرسال طلب الإرجاع',
      message: 'تم استلام طلبك وسنراجع التفاصيل قبل بدء الاسترداد.',
      details: [
        _StateDetail('رقم طلب الإرجاع', _read(args, 'returnId', _referenceVisual ? '#RT-84521' : 'قيد الإنشاء'), Icons.assignment_turned_in_outlined),
        _StateDetail('المبلغ المتوقع', _read(args, 'refundAmount', _referenceVisual ? '120 ر.س' : 'حسب العناصر المقبولة'), Icons.payments_outlined),
        _StateDetail('الحالة', 'قيد المراجعة', Icons.schedule_rounded),
      ],
      primaryLabel: 'متابعة حالة الإرجاع',
      onPrimary: () => Navigator.pushNamed(context, '/refund-status'),
      secondaryLabel: 'العودة إلى طلباتي',
      onSecondary: () => Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => route.isFirst),
    );
  }
}

class PixelWalletTopUpSuccessScreen extends StatelessWidget {
  const PixelWalletTopUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = _args(context);
    return _IllustratedStatePage(
      appBarTitle: '',
      illustration: const _WalletSuccessIllustration(),
      title: 'تم شحن محفظتك بنجاح',
      message: 'تمت إضافة المبلغ إلى رصيد محفظتك ويمكنك استخدامه مباشرة.',
      details: [
        _StateDetail('المبلغ المضاف', _read(args, 'amount', _referenceVisual ? '1,000 ر.س' : 'حسب عملية الشحن'), Icons.add_card_rounded),
        _StateDetail('الحالة', 'مكتملة', Icons.verified_outlined),
        _StateDetail('الرصيد', _read(args, 'balance', _referenceVisual ? '2,850 ر.س' : 'يعرض من المحفظة'), Icons.account_balance_wallet_outlined),
      ],
      primaryLabel: 'العودة للمحفظة',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(context, '/wallet', (route) => route.isFirst),
      secondaryLabel: 'عرض العمليات',
      onSecondary: () => Navigator.pushNamed(context, '/wallet-transactions'),
    );
  }
}

class _IllustratedStatePage extends StatelessWidget {
  const _IllustratedStatePage({
    required this.appBarTitle,
    required this.illustration,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.details = const [],
    this.secondaryLabel,
    this.onSecondary,
  });

  final String appBarTitle;
  final Widget illustration;
  final String title;
  final String message;
  final List<_StateDetail> details;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: appBarTitle.isEmpty ? const MazraaAppBar() : MazraaAppBar(title: appBarTitle),
        body: BotanicalBackdrop(
          dense: true,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Center(child: illustration),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.65),
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < details.length; i++) ...[
                          _StateDetailRow(detail: details[i]),
                          if (i != details.length - 1) const Divider(height: 1, color: AppColors.border),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: onPrimary,
                    icon: const Icon(Icons.eco_outlined),
                    label: Text(primaryLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                  ),
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 9),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      child: Text(secondaryLabel!, style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _StateDetail {
  const _StateDetail(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _StateDetailRow extends StatelessWidget {
  const _StateDetailRow({required this.detail});
  final _StateDetail detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.forestSoft,
              child: Icon(detail.icon, size: 18, color: AppColors.forestDark),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(detail.label, style: const TextStyle(color: AppColors.muted, fontSize: 11.5, fontWeight: FontWeight.w700))),
            Flexible(
              child: Text(detail.value, textAlign: TextAlign.end, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      );
}

class _SuccessWreath extends StatelessWidget {
  const _SuccessWreath({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 170,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final item in const [
              (-58.0, -36.0, -0.5),
              (-66.0, 18.0, -0.2),
              (-36.0, 58.0, 0.2),
              (36.0, 58.0, -0.2),
              (66.0, 18.0, 0.2),
              (58.0, -36.0, 0.5),
            ])
              Transform.translate(
                offset: Offset(item.$1, item.$2),
                child: Transform.rotate(
                  angle: item.$3,
                  child: const Icon(Icons.eco_rounded, color: Color(0xFF8FAA7A), size: 38),
                ),
              ),
            Container(
              width: 108,
              height: 108,
              decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
            ),
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
          ],
        ),
      );
}

class _AddressIllustration extends StatelessWidget {
  const _AddressIllustration();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 200,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 168, height: 120, decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(70))),
            const Positioned(left: 18, bottom: 8, child: Icon(Icons.eco_rounded, size: 66, color: Color(0xFF9DB889))),
            const Positioned(right: 22, top: 18, child: Icon(Icons.wb_sunny_outlined, size: 38, color: AppColors.terracotta)),
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.home_work_rounded, color: AppColors.forestDark, size: 52),
            ),
            const Positioned(right: 42, bottom: 22, child: Icon(Icons.location_on_rounded, color: AppColors.terracotta, size: 40)),
          ],
        ),
      );
}

class _OfflineIllustration extends StatelessWidget {
  const _OfflineIllustration();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 190,
        height: 165,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 145, height: 115, decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(65))),
            const Positioned(left: 8, bottom: 10, child: Icon(Icons.grass_rounded, color: Color(0xFF92AB7C), size: 68)),
            const Positioned(right: 12, top: 8, child: Icon(Icons.eco_rounded, color: AppColors.terracotta, size: 54)),
            const Icon(Icons.wifi_off_rounded, color: AppColors.forestDark, size: 75),
          ],
        ),
      );
}

class _ReturnIllustration extends StatelessWidget {
  const _ReturnIllustration();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 180,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const _SuccessWreath(icon: Icons.check_rounded),
            Positioned(
              bottom: 5,
              child: Container(
                width: 58,
                height: 45,
                decoration: BoxDecoration(color: const Color(0xFFD79A63), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      );
}

class _WalletSuccessIllustration extends StatelessWidget {
  const _WalletSuccessIllustration();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 190,
        height: 165,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(left: 8, bottom: 8, child: Icon(Icons.eco_rounded, color: Color(0xFF8FAA7A), size: 68)),
            const Positioned(right: 6, top: 6, child: Icon(Icons.grass_rounded, color: AppColors.terracotta, size: 56)),
            Container(
              width: 120,
              height: 95,
              decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 62),
            ),
            const Positioned(right: 28, top: 20, child: CircleAvatar(radius: 24, backgroundColor: AppColors.forest, child: Icon(Icons.check_rounded, color: Colors.white, size: 28))),
          ],
        ),
      );
}

Map<String, dynamic> _args(BuildContext context) {
  final value = ModalRoute.of(context)?.settings.arguments;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry(key.toString(), item));
  return const <String, dynamic>{};
}

String _read(Map<String, dynamic> args, String key, String fallback) {
  final value = args[key];
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}
