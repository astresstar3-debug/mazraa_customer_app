import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class MatchedPhoneVerificationScreen extends StatelessWidget {
  const MatchedPhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'التحقق من رقم الهاتف',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroIcon(icon: Icons.phonelink_lock_rounded),
            const SizedBox(height: 18),
            const Text('أدخل رمز التحقق', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('أرسلنا رمزًا مكونًا من 4 أرقام إلى +966 50 123 4567', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  width: 56,
                  height: 62,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Text(['2', '8', '4', '1'][i], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.forestDark)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('إعادة الإرسال خلال 00:42', textAlign: TextAlign.center, style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('متابعة'))),
          ],
        ),
      );
}

class MatchedLocationPermissionScreen extends StatelessWidget {
  const MatchedLocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: '',
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .78,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 190, height: 190, decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle), child: const Icon(Icons.map_rounded, size: 96, color: AppColors.forest)),
                const SizedBox(height: 24),
                const Text('فعّل موقعك', style: TextStyle(color: AppColors.forestDark, fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('نستخدم موقعك لعرض المتاجر والمنتجات القريبة وتحديد عنوان التوصيل بدقة.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.6)),
                const SizedBox(height: 28),
                SizedBox(width: double.infinity, height: 54, child: FilledButton.icon(onPressed: () => Navigator.pushReplacementNamed(context, '/location'), icon: const Icon(Icons.my_location_rounded), label: const Text('السماح بالموقع'))),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, height: 52, child: OutlinedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/location'), child: const Text('إدخال يدويًا'))),
              ],
            ),
          ),
        ),
      );
}

class MatchedLocationPickerScreen extends StatelessWidget {
  const MatchedLocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تحديد الموقع',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(decoration: InputDecoration(hintText: 'ابحث عن موقع', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 12),
            Container(
              height: 430,
              decoration: BoxDecoration(color: const Color(0xFFE5EEDC), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                  const Icon(Icons.location_on_rounded, color: AppColors.forestDark, size: 58),
                  PositionedDirectional(bottom: 12, end: 12, child: FloatingActionButton.small(onPressed: () {}, child: const Icon(Icons.my_location_rounded))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.border)),
              child: const Row(children: [Icon(Icons.location_on_outlined, color: AppColors.forestDark), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الموقع المحدد', style: TextStyle(fontWeight: FontWeight.w900)), Text('الرياض - حي النخيل', style: TextStyle(color: AppColors.muted))]))]),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('تأكيد الموقع'))),
          ],
        ),
      );
}

class _BaseScreen extends StatelessWidget {
  const _BaseScreen({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: title.isEmpty ? null : MazraaAppBar(title: title),
        body: BotanicalBackdrop(dense: true, child: AppPage(padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 28), child: child)),
      );
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 126, height: 126, decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle), child: Icon(icon, size: 62, color: AppColors.forest)));
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
