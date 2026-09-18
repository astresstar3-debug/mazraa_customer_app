import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class ConnectedPhoneVerificationScreen extends StatefulWidget {
  const ConnectedPhoneVerificationScreen({super.key});

  @override
  State<ConnectedPhoneVerificationScreen> createState() =>
      _ConnectedPhoneVerificationScreenState();
}

class _ConnectedPhoneVerificationScreenState
    extends State<ConnectedPhoneVerificationScreen> {
  final phone = TextEditingController();
  final code = TextEditingController();
  bool sent = false;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    phone.dispose();
    code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final value = phone.text.trim();
    if (value.isEmpty) {
      setState(() => error = 'أدخل رقم الهاتف أولًا.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await AppScope.of(context).authRepository.requestPhoneOtp(value);
      if (mounted) setState(() => sent = true);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiException ? e.message : 'تعذر إرسال الرمز.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _verify() async {
    if (code.text.trim().isEmpty) {
      setState(() => error = 'أدخل رمز التحقق.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final app = AppScope.of(context);
    try {
      final session = await app.authRepository.verifyPhoneOtp(
        phone: phone.text.trim(),
        code: code.text.trim(),
      );
      await app.applyAuthenticatedSession(session);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiException ? e.message : 'تعذر التحقق من الرمز.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 820;
              final heroHeight = compact ? 180.0 : 210.0;
              final bottomClearance = compact ? 118.0 : 150.0;

              return Stack(
                children: [
                  const PositionedDirectional(
                    bottom: 0,
                    start: 0,
                    end: 0,
                    child: IgnorePointer(child: _VerificationLandscape()),
                  ),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsetsDirectional.fromSTEB(22, 8, 22, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _VerificationHeader(compact: compact),
                          SizedBox(height: compact ? 8 : 16),
                          _VerificationHero(height: heroHeight),
                          SizedBox(height: compact ? 10 : 18),
                          Text(
                            sent ? 'أدخل رمز التحقق' : 'تحقق من رقم جوالك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontSize: compact ? 28 : 32,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sent
                                ? 'أرسلنا الرمز إلى ${phone.text.trim()}'
                                : 'أدخل رقم الجوال لنرسل إليك رمز التحقق',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF7E9475),
                              fontSize: compact ? 13 : 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: compact ? 18 : 24),
                          if (!sent) ...[
                            _VerificationField(
                              child: TextField(
                                controller: phone,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!loading) _send();
                                },
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'رقم الجوال',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF909282),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.forestDark,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 16 : 21),
                            _VerificationButton(
                              label: loading
                                  ? 'جاري الإرسال...'
                                  : 'إرسال رمز التحقق',
                              onPressed: loading ? null : _send,
                            ),
                          ] else ...[
                            _OtpBoxes(controller: code),
                            SizedBox(height: compact ? 12 : 18),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  color: AppColors.terracotta,
                                  size: 23,
                                ),
                                const Text(
                                  'لم يصلك الرمز؟',
                                  style: TextStyle(
                                    color: AppColors.forestDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextButton(
                                  onPressed: loading ? null : _send,
                                  child: const Text(
                                    'إعادة الإرسال',
                                    style: TextStyle(
                                      color: AppColors.terracotta,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : () => setState(() {
                                        sent = false;
                                        code.clear();
                                        error = null;
                                      }),
                              child: const Text(
                                'تغيير رقم الجوال',
                                style: TextStyle(
                                  color: AppColors.forestDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 8 : 12),
                            _VerificationButton(
                              label: loading ? 'جاري التحقق...' : 'متابعة',
                              onPressed: loading ? null : _verify,
                            ),
                          ],
                          if (error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          SizedBox(height: bottomClearance),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: compact ? 74 : 88,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppLogo(size: compact ? 62 : 74, showName: true),
            ),
            Center(
              child: Text(
                'التحقق من رقم الجوال',
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.forestDark,
                  size: 23,
                ),
              ),
            ),
          ],
        ),
      );
}

class _VerificationField extends StatelessWidget {
  const _VerificationField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5DDCC)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );
}

class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({required this.controller});

  final TextEditingController controller;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _focusNode.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final boxWidth = ((constraints.maxWidth - (gap * 3)) / 4)
            .clamp(52.0, 68.0);

        return GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 1,
                height: 1,
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final digit = index < value.length ? value[index] : '';
                  return Container(
                    width: boxWidth,
                    height: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFEFA),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: digit.isEmpty
                            ? const Color(0xFFE4D9C4)
                            : AppColors.forest,
                        width: 1.3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x09000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      digit,
                      style: const TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VerificationButton extends StatelessWidget {
  const _VerificationButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0A4728), Color(0xFF226A3D)],
          ),
          borderRadius: BorderRadius.circular(21),
          boxShadow: const [
            BoxShadow(
              color: Color(0x160D4328),
              blurRadius: 17,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PositionedDirectional(
                start: 9,
                child: Icon(
                  Icons.eco_rounded,
                  size: 29,
                  color: Colors.white.withValues(alpha: .16),
                ),
              ),
              PositionedDirectional(
                end: 9,
                child: Icon(
                  Icons.eco_rounded,
                  size: 29,
                  color: Colors.white.withValues(alpha: .14),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}

class _VerificationHero extends StatelessWidget {
  const _VerificationHero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scale = height / 210;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180 * scale,
            height: 180 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFFF7EEDB),
              shape: BoxShape.circle,
            ),
          ),
          PositionedDirectional(
            start: 46,
            bottom: 25,
            child: Transform.rotate(
              angle: -.48,
              child: Icon(
                Icons.eco_rounded,
                size: 78 * scale,
                color: const Color(0xFF38693F),
              ),
            ),
          ),
          PositionedDirectional(
            end: 46,
            bottom: 25,
            child: Transform.rotate(
              angle: .48,
              child: Icon(
                Icons.eco_rounded,
                size: 78 * scale,
                color: const Color(0xFF38693F),
              ),
            ),
          ),
          Container(
            width: 100 * scale,
            height: 100 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF28613C),
              borderRadius: BorderRadius.circular(22 * scale),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x170D4328),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.key_rounded,
              size: 50 * scale,
              color: const Color(0xFFF7EDD4),
            ),
          ),
          Positioned(
            top: 27 * scale,
            child: Container(
              width: 54 * scale,
              height: 66 * scale,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.terracotta,
                  width: 10 * scale,
                ),
                borderRadius: BorderRadius.circular(38),
              ),
            ),
          ),
          PositionedDirectional(
            top: 52 * scale,
            end: 76,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.terracotta,
              size: 23 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationLandscape extends StatelessWidget {
  const _VerificationLandscape();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 150,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _VerificationLandscapePainter()),
            ),
            PositionedDirectional(
              start: -30,
              bottom: -22,
              child: Transform.rotate(
                angle: -.25,
                child: Icon(
                  Icons.eco_rounded,
                  size: 122,
                  color: const Color(0xFF688557).withValues(alpha: .58),
                ),
              ),
            ),
            PositionedDirectional(
              end: -25,
              bottom: -15,
              child: Transform.rotate(
                angle: .32,
                child: Icon(
                  Icons.eco_rounded,
                  size: 115,
                  color: const Color(0xFF688557).withValues(alpha: .56),
                ),
              ),
            ),
          ],
        ),
      );
}

class _VerificationLandscapePainter extends CustomPainter {
  const _VerificationLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cream = Paint()
      ..color = const Color(0xFFF1E8CD).withValues(alpha: .82);
    final green = Paint()
      ..color = const Color(0xFFB6C09A).withValues(alpha: .62);

    final p1 = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(
        size.width * .25,
        size.height * .47,
        size.width * .48,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .92,
        size.width,
        size.height * .58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, cream);

    final p2 = Path()
      ..moveTo(size.width * .48, size.height)
      ..quadraticBezierTo(
        size.width * .67,
        size.height * .72,
        size.width,
        size.height * .76,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(p2, green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
