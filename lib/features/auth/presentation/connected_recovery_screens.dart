import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/auth_repository.dart';

class ConnectedForgotPasswordScreen extends StatefulWidget {
  const ConnectedForgotPasswordScreen({super.key});

  @override
  State<ConnectedForgotPasswordScreen> createState() =>
      _ConnectedForgotPasswordScreenState();
}

class _ConnectedForgotPasswordScreenState
    extends State<ConnectedForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'أدخل البريد الإلكتروني الصحيح للحساب.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthRepository(AppScope.of(context).client).forgotPassword(email);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConnectedResetPasswordScreen(email: email),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is ApiException
          ? error.message
          : 'تعذر إرسال طلب استعادة كلمة المرور.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
                      child: _RecoveryBottomGarden(),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(22, 8, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 82,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const AppLogo(size: 74),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: IconButton(
                                    onPressed: () => Navigator.maybePop(context),
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColors.forestDark,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.eco_rounded, color: Color(0xFF91A978), size: 28),
                              SizedBox(width: 12),
                              Text(
                                'استعادة كلمة المرور',
                                style: TextStyle(
                                  color: AppColors.forestDark,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.eco_rounded, color: Color(0xFF91A978), size: 28),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const _RecoveryHero(),
                          const SizedBox(height: 20),
                          const Text(
                            'هل نسيت كلمة المرور؟',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 31,
                              height: 1.18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'أدخل البريد الإلكتروني المرتبط بحسابك لإرسال رمز التحقق',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 14,
                              height: 1.65,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _RecoveryFieldShell(
                            child: TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'البريد الإلكتروني',
                                hintStyle: TextStyle(color: Color(0xFF8D8C7D), fontSize: 14),
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.forestDark, size: 24),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 9),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 22),
                          _RecoveryGradientButton(
                            label: _loading ? 'جاري الإرسال...' : 'إرسال رمز التحقق',
                            onPressed: _loading ? null : _submit,
                          ),
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                            icon: const Icon(Icons.arrow_back_rounded, size: 20),
                            label: const Text(
                              'العودة لتسجيل الدخول',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            style: TextButton.styleFrom(foregroundColor: AppColors.forestDark),
                          ),
                          const SizedBox(height: 215),
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

class ConnectedResetPasswordScreen extends StatefulWidget {
  const ConnectedResetPasswordScreen({super.key, this.email = ''});
  final String email;

  @override
  State<ConnectedResetPasswordScreen> createState() =>
      _ConnectedResetPasswordScreenState();
}

class _ConnectedResetPasswordScreenState
    extends State<ConnectedResetPasswordScreen> {
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_token.text.trim().isEmpty) {
      setState(() => _error = 'أدخل رمز الاستعادة الذي وصلك بالبريد.');
      return;
    }
    if (_password.text.length < 8) {
      setState(() => _error = 'كلمة المرور يجب ألا تقل عن 8 أحرف.');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'تأكيد كلمة المرور غير مطابق.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthRepository(AppScope.of(context).client).resetPassword(
        token: _token.text,
        newPassword: _password.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور. يمكنك تسجيل الدخول الآن.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is ApiException
          ? error.message
          : 'تعذر إعادة تعيين كلمة المرور.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
                      child: _RecoveryBottomGarden(),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(22, 8, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 82,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const AppLogo(size: 72),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: IconButton(
                                    onPressed: () => Navigator.maybePop(context),
                                    icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.forestDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _RecoveryHero(compact: true),
                          const SizedBox(height: 17),
                          const Text(
                            'إعادة تعيين كلمة المرور',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (widget.email.isNotEmpty) ...[
                            const SizedBox(height: 9),
                            Text(
                              'تم إرسال رمز الاستعادة إلى ${widget.email}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF788670), fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 26),
                          _RecoveryFieldShell(
                            child: TextField(
                              controller: _token,
                              decoration: const InputDecoration(
                                hintText: 'رمز الاستعادة',
                                hintStyle: TextStyle(color: Color(0xFF8D8C7D), fontSize: 14),
                                prefixIcon: Icon(Icons.key_rounded, color: AppColors.forestDark),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _RecoveryFieldShell(
                            child: TextField(
                              controller: _password,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'كلمة المرور الجديدة',
                                hintStyle: const TextStyle(color: Color(0xFF8D8C7D), fontSize: 14),
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.forestDark),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFF6D7A65),
                                  ),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _RecoveryFieldShell(
                            child: TextField(
                              controller: _confirm,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                hintText: 'تأكيد كلمة المرور',
                                hintStyle: const TextStyle(color: Color(0xFF8D8C7D), fontSize: 14),
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.forestDark),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  icon: Icon(
                                    _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFF6D7A65),
                                  ),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
                          ],
                          const SizedBox(height: 22),
                          _RecoveryGradientButton(
                            label: _loading ? 'جاري التحديث...' : 'تحديث كلمة المرور',
                            onPressed: _loading ? null : _reset,
                          ),
                          const SizedBox(height: 205),
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

class _RecoveryFieldShell extends StatelessWidget {
  const _RecoveryFieldShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFE3DDCD), width: 1.05),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 5)),
          ],
        ),
        child: child,
      );
}

class _RecoveryGradientButton extends StatelessWidget {
  const _RecoveryGradientButton({required this.label, required this.onPressed});

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
          boxShadow: const [BoxShadow(color: Color(0x150D4328), blurRadius: 16, offset: Offset(0, 7))],
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
                start: 8,
                child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .18), size: 32),
              ),
              PositionedDirectional(
                end: 8,
                child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .15), size: 32),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      );
}

class _RecoveryHero extends StatelessWidget {
  const _RecoveryHero({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 175.0 : 250.0;
    final circle = compact ? 145.0 : 205.0;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: circle,
            height: circle,
            decoration: const BoxDecoration(
              color: Color(0xFFF6EDD8),
              shape: BoxShape.circle,
            ),
          ),
          PositionedDirectional(
            bottom: compact ? 17 : 26,
            start: compact ? 46 : 38,
            child: Transform.rotate(
              angle: -.42,
              child: Icon(Icons.eco_rounded, color: const Color(0xFF4D7647), size: compact ? 76 : 98),
            ),
          ),
          PositionedDirectional(
            bottom: compact ? 17 : 24,
            end: compact ? 46 : 38,
            child: Transform.rotate(
              angle: .42,
              child: Icon(Icons.eco_rounded, color: const Color(0xFF5D804E), size: compact ? 74 : 96),
            ),
          ),
          Container(
            width: compact ? 92 : 120,
            height: compact ? 100 : 128,
            decoration: BoxDecoration(
              color: const Color(0xFF28613C),
              borderRadius: BorderRadius.circular(compact ? 23 : 28),
              boxShadow: const [BoxShadow(color: Color(0x180D4328), blurRadius: 16, offset: Offset(0, 6))],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.key_rounded, color: const Color(0xFFF9F1D7), size: compact ? 48 : 62),
          ),
          Positioned(
            top: compact ? 24 : 32,
            child: Container(
              width: compact ? 52 : 68,
              height: compact ? 60 : 78,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.terracotta, width: compact ? 9 : 11),
                borderRadius: BorderRadius.circular(42),
              ),
            ),
          ),
          PositionedDirectional(
            top: compact ? 53 : 70,
            end: compact ? 43 : 55,
            child: Icon(Icons.auto_awesome, color: AppColors.terracotta, size: compact ? 20 : 26),
          ),
        ],
      ),
    );
  }
}

class _RecoveryBottomGarden extends StatelessWidget {
  const _RecoveryBottomGarden();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 205,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _RecoveryLandscapePainter())),
            PositionedDirectional(
              bottom: -28,
              start: -36,
              child: Transform.rotate(
                angle: -.28,
                child: Icon(Icons.eco_rounded, size: 165, color: const Color(0xFF527648).withValues(alpha: .74)),
              ),
            ),
            PositionedDirectional(
              bottom: -30,
              end: -36,
              child: Transform.rotate(
                angle: .30,
                child: Icon(Icons.eco_rounded, size: 165, color: const Color(0xFF527648).withValues(alpha: .72)),
              ),
            ),
            PositionedDirectional(
              bottom: 50,
              start: 35,
              child: Icon(Icons.circle, color: AppColors.terracotta.withValues(alpha: .82), size: 15),
            ),
            PositionedDirectional(
              bottom: 56,
              end: 38,
              child: Icon(Icons.circle, color: AppColors.terracotta.withValues(alpha: .80), size: 14),
            ),
          ],
        ),
      );
}

class _RecoveryLandscapePainter extends CustomPainter {
  const _RecoveryLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cream = Paint()..color = const Color(0xFFF4EAD0).withValues(alpha: .87);
    final pale = Paint()..color = const Color(0xFFE7DDBA).withValues(alpha: .68);

    final left = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .64)
      ..quadraticBezierTo(size.width * .14, size.height * .47, size.width * .31, size.height)
      ..close();
    canvas.drawPath(left, cream);

    final right = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, size.height * .64)
      ..quadraticBezierTo(size.width * .84, size.height * .46, size.width * .68, size.height)
      ..close();
    canvas.drawPath(right, cream);

    final floor = Path()
      ..moveTo(0, size.height * .92)
      ..quadraticBezierTo(size.width * .27, size.height * .80, size.width * .50, size.height * .95)
      ..quadraticBezierTo(size.width * .73, size.height * .80, size.width, size.height * .91)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(floor, pale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
