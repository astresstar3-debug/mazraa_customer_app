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
            const _OtpHero(),
            const SizedBox(height: 18),
            const Text(
              'أدخل رمز التحقق',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.forestDark,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'أرسلنا رمزًا مكونًا من 4 أرقام إلى +966 50 123 4567',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 11.5),
            ),
            const SizedBox(height: 24),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    width: 56,
                    height: 62,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      ['2', '8', '4', '1'][i],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.forestDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 17),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.terracotta, size: 16),
                SizedBox(width: 5),
                Text(
                  'إعادة الإرسال خلال 00:42',
                  style: TextStyle(
                    color: AppColors.terracotta,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            TextButton(onPressed: () {}, child: const Text('تغيير رقم الجوال')),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('متابعة', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      );
}

class MatchedLocationPermissionScreen extends StatelessWidget {
  const MatchedLocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: BotanicalBackdrop(
          dense: false,
          child: SafeArea(
            child: AppPage(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 28),
              child: Column(
                children: [
                  const Center(child: AppLogo(size: 76, showName: true)),
                  const Spacer(),
                  const _PermissionHero(),
                  const SizedBox(height: 22),
                  const Text(
                    'فعّل موقعك',
                    style: TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'نستخدم موقعك لعرض المتاجر والمنتجات القريبة وتحديد عنوان التوصيل بدقة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.65),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.forest, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'لن نشارك موقعك دون إذنك',
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/location'),
                      icon: const Icon(Icons.location_on_rounded),
                      label: const Text('السماح بالموقع', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/location'),
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: const Text('الإدخال يدويًا'),
                    ),
                  ),
                ],
              ),
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
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن موقع',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 11),
            Container(
              height: 455,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFC8C49A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .68),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(Icons.location_on_rounded, color: AppColors.forestDark, size: 62),
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'الرياض',
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 12,
                    end: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'map-current-location',
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.forestDark,
                      child: const Icon(Icons.my_location_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.near_me_rounded),
              label: const Text('استخدام موقعي الحالي'),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.forestDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الموقع المحدد', style: TextStyle(fontWeight: FontWeight.w900)),
                        Text('الرياض - حي النخيل', style: TextStyle(color: AppColors.muted, fontSize: 10.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تأكيد الموقع', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
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
        body: BotanicalBackdrop(
          dense: false,
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 28),
            child: child,
          ),
        ),
      );
}

class _OtpHero extends StatelessWidget {
  const _OtpHero();

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 160,
          height: 145,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PositionedDirectional(
                start: 5,
                bottom: 5,
                child: Transform.rotate(
                  angle: -.5,
                  child: Icon(
                    Icons.eco_rounded,
                    size: 76,
                    color: AppColors.forest.withValues(alpha: .24),
                  ),
                ),
              ),
              PositionedDirectional(
                end: 5,
                bottom: 5,
                child: Transform.rotate(
                  angle: .5,
                  child: Icon(
                    Icons.eco_rounded,
                    size: 76,
                    color: AppColors.terracotta.withValues(alpha: .20),
                  ),
                ),
              ),
              Container(
                width: 102,
                height: 102,
                decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                child: const Icon(Icons.lock_rounded, size: 55, color: AppColors.forest),
              ),
            ],
          ),
        ),
      );
}

class _PermissionHero extends StatelessWidget {
  const _PermissionHero();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 300,
        height: 245,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 270,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E6C8),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
            PositionedDirectional(
              start: 45,
              bottom: 42,
              child: Icon(Icons.eco_rounded, color: AppColors.forest.withValues(alpha: .55), size: 80),
            ),
            PositionedDirectional(
              end: 40,
              bottom: 40,
              child: Icon(Icons.local_shipping_rounded, color: AppColors.forest, size: 66),
            ),
            const Positioned(
              top: 17,
              child: Icon(Icons.location_on_rounded, color: AppColors.terracotta, size: 100),
            ),
            const Positioned(
              bottom: 45,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.eco_rounded, color: AppColors.forest, size: 36),
              ),
            ),
          ],
        ),
      );
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFFB7B281),
      Color(0xFFC7C195),
      Color(0xFFA4AD79),
      Color(0xFFD3C8A3),
      Color(0xFF969D6F),
      Color(0xFFD8D0B2),
    ];
    const columns = 6;
    const rows = 9;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final index = (row * 3 + column * 5) % colors.length;
        final rect = Rect.fromLTWH(
          column * cellWidth,
          row * cellHeight,
          cellWidth + 1,
          cellHeight + 1,
        );
        canvas.drawRect(rect, Paint()..color = colors[index]);
        if ((row + column) % 3 == 0) {
          final stripe = Paint()
            ..color = Colors.white.withValues(alpha: .13)
            ..strokeWidth = 2;
          for (var line = 1; line < 5; line++) {
            final y = rect.top + rect.height * line / 5;
            canvas.drawLine(Offset(rect.left + 3, y), Offset(rect.right - 3, y), stripe);
          }
        }
      }
    }
    final mainRoad = Paint()
      ..color = const Color(0xFFECE4D0)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-25, size.height * .86),
      Offset(size.width + 28, size.height * .18),
      mainRoad,
    );
    canvas.drawLine(
      Offset(size.width * .18, -20),
      Offset(size.width * .72, size.height + 25),
      mainRoad,
    );
    final smallRoad = Paint()
      ..color = const Color(0xFFF5EFE0)
      ..strokeWidth = 5;
    for (double y = 70; y < size.height; y += 105) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 26), smallRoad);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
