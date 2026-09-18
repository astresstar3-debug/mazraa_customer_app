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
            padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLogo(size: 58, showName: true),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 22),
                          child: Text(
                            'التحقق من رقم الجوال',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 19,
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
                const SizedBox(height: 8),
                const _OtpHero(),
                const SizedBox(height: 14),
                const Text(
                  'أدخل رمز التحقق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 31,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'أرسلنا الرمز إلى +966 50 123 4567',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF83947A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 58,
                        height: 62,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEFA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE6DECE),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0B000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
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
                const SizedBox(height: 18),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: AppColors.terracotta,
                      size: 24,
                    ),
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
                const SizedBox(height: 4),
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
                const SizedBox(height: 6),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PositionedDirectional(
                          start: 3,
                          child: Icon(
                            Icons.eco_rounded,
                            color: Colors.white.withValues(alpha: .18),
                            size: 28,
                          ),
                        ),
                        PositionedDirectional(
                          end: 3,
                          child: Icon(
                            Icons.eco_rounded,
                            color: Colors.white.withValues(alpha: .17),
                            size: 28,
                          ),
                        ),
                        const Text(
                          'متابعة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
                  child: Column(
                    children: [
                      const Center(child: AppLogo(size: 72, showName: true)),
                      const Spacer(),
                      const _PermissionHero(),
                      const SizedBox(height: 14),
                      const Text(
                        'فعّل موقعك',
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'نستخدم موقعك لعرض المزادات القريبة\nوحساب تكلفة التوصيل بدقة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            color: AppColors.forest,
                            size: 20,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'لن نشارك موقعك دون إذنك',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/location',
                          ),
                          icon: const Icon(Icons.location_on_rounded),
                          label: const Text(
                            'السماح بالموقع',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/location',
                          ),
                          icon: const Icon(Icons.keyboard_alt_outlined),
                          label: const Text(
                            'الإدخال يدويًا',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 86,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      const AppLogo(size: 58),
                      PositionedDirectional(
                        start: 0,
                        top: 25,
                        child: IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.forestDark,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تحديد الموقع',
                              style: TextStyle(
                                color: AppColors.forestDark,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.eco_rounded,
                              color: AppColors.forestDark,
                              size: 27,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن موقع',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFFFFEFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 390,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9BE92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: _MapPainter()),
                      ),
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB7CB91).withValues(alpha: .50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.forestDark,
                        size: 68,
                      ),
                      const PositionedDirectional(
                        top: 34,
                        end: 22,
                        child: _MapLabel('المزرعة'),
                      ),
                      const PositionedDirectional(
                        top: 145,
                        start: 22,
                        child: _MapLabel('مزارع النخيل'),
                      ),
                      const PositionedDirectional(
                        bottom: 70,
                        end: 24,
                        child: _MapLabel('وادي حنيفة'),
                      ),
                      PositionedDirectional(
                        bottom: 14,
                        end: 14,
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
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.near_me_rounded),
                    label: const Text(
                      'استخدام موقعي الحالي',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: AppColors.forestDark,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الرياض، حي النخيل، شارع الملك فهد',
                          style: TextStyle(
                            color: AppColors.forestDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'تأكيد الموقع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _OtpHero extends StatelessWidget {
  const _OtpHero();

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 250,
          height: 185,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6EBD3),
                  shape: BoxShape.circle,
                ),
              ),
              PositionedDirectional(
                start: 30,
                bottom: 20,
                child: Transform.rotate(
                  angle: -.50,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 82,
                    color: Color(0xFF4C7948),
                  ),
                ),
              ),
              PositionedDirectional(
                end: 28,
                bottom: 18,
                child: Transform.rotate(
                  angle: .48,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 80,
                    color: Color(0xFF628357),
                  ),
                ),
              ),
              Positioned(
                top: 18,
                child: Container(
                  width: 66,
                  height: 73,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.terracotta,
                      width: 10,
                    ),
                    borderRadius: BorderRadius.circular(42),
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 104,
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D653D),
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x170D4328),
                      blurRadius: 17,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 54,
                  color: Color(0xFFFFF7E4),
                ),
              ),
              const PositionedDirectional(
                top: 39,
                end: 41,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.terracotta,
                  size: 25,
                ),
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
        height: 112,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _OtpLandscapePainter()),
            ),
            PositionedDirectional(
              bottom: -26,
              start: -24,
              child: Transform.rotate(
                angle: -.30,
                child: Icon(
                  Icons.eco_rounded,
                  size: 100,
                  color: const Color(0xFF668653).withValues(alpha: .60),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: -26,
              end: -24,
              child: Transform.rotate(
                angle: .31,
                child: Icon(
                  Icons.eco_rounded,
                  size: 100,
                  color: const Color(0xFF668653).withValues(alpha: .58),
                ),
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
    final beige = Paint()
      ..color = const Color(0xFFECE3C7).withValues(alpha: .82);
    final green = Paint()
      ..color = const Color(0xFFBCC79D).withValues(alpha: .66);
    final light = Paint()
      ..color = const Color(0xFFF4EBD6).withValues(alpha: .88);

    final p1 = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .43,
        size.width * .48,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .75,
        size.height,
        size.width,
        size.height * .64,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, light);

    final p2 = Path()
      ..moveTo(0, size.height * .89)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .67,
        size.width * .57,
        size.height * .84,
      )
      ..quadraticBezierTo(
        size.width * .77,
        size.height * .96,
        size.width,
        size.height * .77,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p2, beige);

    final p3 = Path()
      ..moveTo(size.width * .45, size.height)
      ..quadraticBezierTo(
        size.width * .70,
        size.height * .65,
        size.width,
        size.height * .80,
      )
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
        width: 310,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 270,
              height: 176,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E6C8),
                borderRadius: BorderRadius.circular(70),
              ),
            ),
            PositionedDirectional(
              start: 32,
              bottom: 35,
              child: Icon(
                Icons.eco_rounded,
                color: AppColors.forest.withValues(alpha: .55),
                size: 96,
              ),
            ),
            PositionedDirectional(
              end: 30,
              bottom: 42,
              child: Icon(
                Icons.local_shipping_rounded,
                color: AppColors.forest,
                size: 70,
              ),
            ),
            const Positioned(
              top: 8,
              child: Icon(
                Icons.location_on_rounded,
                color: AppColors.terracotta,
                size: 126,
              ),
            ),
            const Positioned(
              top: 61,
              child: CircleAvatar(
                radius: 23,
                backgroundColor: Color(0xFFFFF3DA),
                child: Icon(
                  Icons.eco_rounded,
                  color: AppColors.forest,
                  size: 30,
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 18,
              start: 70,
              child: Container(
                width: 112,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D884F),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ],
        ),
      );
}

class _MapLabel extends StatelessWidget {
  const _MapLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.forestDark.withValues(alpha: .84),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFFC9BE8B),
      Color(0xFFD9CCA1),
      Color(0xFFA4AD79),
      Color(0xFFE4D8B8),
      Color(0xFF8E9B66),
      Color(0xFFB6B77E),
    ];
    const columns = 7;
    const rows = 10;
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
        if ((row + column) % 2 == 0) {
          final stripe = Paint()
            ..color = Colors.white.withValues(alpha: .16)
            ..strokeWidth = 1.5;
          for (var line = 1; line < 5; line++) {
            final y = rect.top + rect.height * line / 5;
            canvas.drawLine(
              Offset(rect.left + 2, y),
              Offset(rect.right - 2, y),
              stripe,
            );
          }
        }
      }
    }

    final mainRoad = Paint()
      ..color = const Color(0xFFF2E8D4)
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
      ..color = const Color(0xFFFAF4E7)
      ..strokeWidth = 5;
    for (double y = 55; y < size.height; y += 85) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 24),
        smallRoad,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
