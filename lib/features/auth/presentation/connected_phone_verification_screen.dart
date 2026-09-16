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
    if (phone.text.trim().isEmpty) {
      setState(() => error = 'أدخل رقم الهاتف أولًا.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await AppScope.of(context).authRepository.requestPhoneOtp(phone.text);
      if (mounted) setState(() => sent = true);
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر إرسال الرمز.');
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
        phone: phone.text,
        code: code.text,
      );
      await app.applyAuthenticatedSession(session);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر التحقق من الرمز.');
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
            builder: (context, constraints) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    const PositionedDirectional(
                      bottom: 0,
                      start: 0,
                      end: 0,
                      child: _VerificationLandscape(),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(22, 10, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: const AppLogo(size: 88, showName: true),
                                ),
                                const Center(
                                  child: Text(
                                    'التحقق من رقم الجوال',
                                    style: TextStyle(
                                      color: AppColors.forestDark,
                                      fontSize: 22,
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
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _VerificationHero(),
                          const SizedBox(height: 24),
                          Text(
                            sent ? 'أدخل رمز التحقق' : 'تحقق من رقم جوالك',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 34,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            sent
                                ? 'أرسلنا الرمز إلى ${phone.text.trim()}'
                                : 'أدخل رقم الجوال لنرسل إليك رمز التحقق',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF7E9475),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (!sent) ...[
                            _VerificationField(
                              child: TextField(
                                controller: phone,
                                keyboardType: TextInputType.phone,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'رقم الجوال',
                                  hintStyle: TextStyle(color: Color(0xFF909282), fontSize: 15),
                                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.forestDark),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _VerificationButton(
                              label: loading ? 'جاري الإرسال...' : 'إرسال رمز التحقق',
                              onPressed: loading ? null : _send,
                            ),
                          ] else ...[
                            _OtpBoxes(controller: code),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.schedule_rounded, color: AppColors.terracotta, size: 26),
                                const SizedBox(width: 8),
                                const Text(
                                  'إعادة الإرسال خلال',
                                  style: TextStyle(color: AppColors.forestDark, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
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
                              onPressed: () => setState(() {
                                sent = false;
                                code.clear();
                              }),
                              child: const Text(
                                'تغيير رقم الجوال',
                                style: TextStyle(
                                  color: AppColors.forestDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _VerificationButton(
                              label: loading ? 'جاري التحقق...' : 'متابعة',
                              onPressed: loading ? null : _verify,
                            ),
                          ],
                          if (error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 190),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _VerificationField extends StatelessWidget {
  const _VerificationField({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5DDCC)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 5))],
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
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_focusNode),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final digit = index < value.length ? value[index] : '';
              return Container(
                width: 64,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFEFA),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE4D9C4), width: 1.3),
                  boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Text(
                  digit,
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();
}

class _VerificationButton extends StatelessWidget {
  const _VerificationButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0A4728), Color(0xFF226A3D)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x160D4328), blurRadius: 17, offset: Offset(0, 7))],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PositionedDirectional(
                start: 9,
                child: Icon(Icons.eco_rounded, size: 31, color: Colors.white.withValues(alpha: .16)),
              ),
              PositionedDirectional(
                end: 9,
                child: Icon(Icons.eco_rounded, size: 31, color: Colors.white.withValues(alpha: .14)),
              ),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
}

class _VerificationHero extends StatelessWidget {
  const _VerificationHero();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(color: Color(0xFFF7EEDB), shape: BoxShape.circle),
            ),
            PositionedDirectional(
              start: 42,
              bottom: 35,
              child: Transform.rotate(
                angle: -.48,
                child: const Icon(Icons.eco_rounded, size: 88, color: Color(0xFF38693F)),
              ),
            ),
            PositionedDirectional(
              end: 42,
              bottom: 34,
              child: Transform.rotate(
                angle: .48,
                child: const Icon(Icons.eco_rounded, size: 88, color: Color(0xFF38693F)),
              ),
            ),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFF28613C),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Color(0x170D4328), blurRadius: 14, offset: Offset(0, 6))],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.key_rounded, size: 56, color: Color(0xFFF7EDD4)),
            ),
            Positioned(
              top: 35,
              child: Container(
                width: 60,
                height: 72,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.terracotta, width: 11),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            const PositionedDirectional(top: 65, end: 72, child: Icon(Icons.auto_awesome, color: AppColors.terracotta, size: 26)),
          ],
        ),
      );
}

class _VerificationLandscape extends StatelessWidget {
  const _VerificationLandscape();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 170,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _VerificationLandscapePainter())),
            PositionedDirectional(
              start: -30,
              bottom: -20,
              child: Transform.rotate(
                angle: -.25,
                child: Icon(Icons.eco_rounded, size: 135, color: const Color(0xFF688557).withValues(alpha: .62)),
              ),
            ),
            PositionedDirectional(
              end: -25,
              bottom: -12,
              child: Transform.rotate(
                angle: .32,
                child: Icon(Icons.eco_rounded, size: 125, color: const Color(0xFF688557).withValues(alpha: .60)),
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
    final cream = Paint()..color = const Color(0xFFF1E8CD).withValues(alpha: .82);
    final green = Paint()..color = const Color(0xFFB6C09A).withValues(alpha: .62);

    final p1 = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(size.width * .25, size.height * .47, size.width * .48, size.height * .72)
      ..quadraticBezierTo(size.width * .72, size.height * .92, size.width, size.height * .58)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, cream);

    final p2 = Path()
      ..moveTo(size.width * .48, size.height)
      ..quadraticBezierTo(size.width * .67, size.height * .72, size.width, size.height * .76)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(p2, green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
