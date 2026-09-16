import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class MatchedPhoneVerificationScreen extends StatelessWidget {
  const MatchedPhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 78,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLogo(size: 58, showName: true),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 22),
                          child: Text(
                            'التحقق من رقم الجوال',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.forestDark,
                            size: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 19),
                const _OtpHero(),
                const SizedBox(height: 20),
                const Text(
                  'أدخل رمز التحقق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 31,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'أرسلنا الرمز إلى +966 50 123 4567',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF83947A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 27),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 58,
                        height: 65,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEFA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE6DECE), width: 1.2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0B000000), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                          ['2', '8', '4', '1'][i],
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: AppColors.forestDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_rounded, color: AppColors.terracotta, size: 24),
                    SizedBox(width: 9),
                    Text(
                      'إعادة الإرسال خلال',
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      '00:42',
                      style: TextStyle(
                        color: AppColors.terracotta,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'تغيير رقم الجوال',
                    style: TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xFF0B4D2B), Color(0xFF1D6A3E)],
                    ),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PositionedDirectional(
                          start: 3,
                          child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .18), size: 28),
                        ),
                        PositionedDirectional(
                          end: 3,
                          child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .17), size: 28),
                        ),
                        const Text(
                          'متابعة',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _OtpBottomLandscape(),
              ],
            ),
          ),
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
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
          width: 260,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 188,
                height: 188,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6EBD3),
                  shape: BoxShape.circle,
                ),
              ),
              PositionedDirectional(
                start: 25,
                bottom: 27,
                child: Transform.rotate(
                  angle: -.50,
                  child: const Icon(Icons.eco_rounded, size: 95, color: Color(0xFF4C7948)),
                ),
              ),
              PositionedDirectional(
                end: 23,
                bottom: 24,
                child: Transform.rotate(
                  angle: .48,
                  child: const Icon(Icons.eco_rounded, size: 94, color: Color(0xFF628357)),
                ),
              ),
              Positioned(
                top: 27,
                child: Container(
                  width: 76,
                  height: 82,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.terracotta, width: 11),
                    borderRadius: BorderRadius.circular(45),
                  ),
                ),
              ),
              Container(
                width: 112,
                height: 116,
                margin: const EdgeInsets.only(top: 37),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D653D),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Color(0x170D4328), blurRadius: 17, offset: Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.lock_rounded, size: 60, color: Color(0xFFFFF7E4)),
              ),
              PositionedDirectional(
                top: 47,
                end: 36,
                child: Transform.rotate(
                  angle: .55,
                  child: const Icon(Icons.remove_rounded, color: AppColors.terracotta, size: 32),
                ),
              ),
              PositionedDirectional(
                top: 77,
                start: 30,
                child: const Icon(Icons.circle, color: AppColors.terracotta, size: 10),
              ),
            ],
          ),
        ),
      );
}

class _OtpBottomLandscape extends StatelessWidget {
  const _OtpBottomLandscape();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 160,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _OtpLandscapePainter())),
            PositionedDirectional(
              bottom: -20,
              start: -27,
              child: Transform.rotate(
                angle: -.30,
                child: Icon(Icons.eco_rounded, size: 118, color: const Color(0xFF668653).withValues(alpha: .60)),
              ),
            ),
            PositionedDirectional(
              bottom: -20,
              end: -28,
              child: Transform.rotate(
                angle: .31,
                child: Icon(Icons.eco_rounded, size: 118, color: const Color(0xFF668653).withValues(alpha: .58)),
              ),
            ),
          ],
        ),
      );
}

class _OtpLandscapePainter extends CustomPainter {
  const _OtpLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final beige = Paint()..color = const Color(0xFFECE3C7).withValues(alpha: .82);
    final green = Paint()..color = const Color(0xFFBCC79D).withValues(alpha: .66);
    final light = Paint()..color = const Color(0xFFF4EBD6).withValues(alpha: .88);

    final p1 = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(size.width * .22, size.height * .43, size.width * .48, size.height * .72)
      ..quadraticBezierTo(size.width * .75, size.height, size.width, size.height * .64)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, light);

    final p2 = Path()
      ..moveTo(0, size.height * .89)
      ..quadraticBezierTo(size.width * .28, size.height * .67, size.width * .57, size.height * .84)
      ..quadraticBezierTo(size.width * .77, size.height * .96, size.width, size.height * .77)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p2, beige);

    final p3 = Path()
      ..moveTo(size.width * .45, size.height)
      ..quadraticBezierTo(size.width * .70, size.height * .65, size.width, size.height * .80)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(p3, green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
