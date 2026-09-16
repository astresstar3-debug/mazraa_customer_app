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
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 62,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const AppLogo(size: 58),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.forestDark,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco_rounded, color: Color(0xFF9DAF7F), size: 25),
                    SizedBox(width: 10),
                    Text(
                      'استعادة كلمة المرور',
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.eco_rounded, color: Color(0xFF9DAF7F), size: 25),
                  ],
                ),
                const SizedBox(height: 20),
                const _RecoveryHero(),
                const SizedBox(height: 18),
                const Text(
                  'هل نسيت كلمة المرور؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 27,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'أدخل البريد الإلكتروني المرتبط بحسابك لإرسال رمز التحقق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 12.5,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 23),
                _RecoveryFieldShell(
                  child: TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'البريد الإلكتروني',
                      hintStyle: TextStyle(color: Color(0xFF8D8C7D), fontSize: 12.5),
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.forestDark),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error, fontSize: 11.5),
                  ),
                ],
                const SizedBox(height: 18),
                _RecoveryGradientButton(
                  label: _loading ? 'جاري الإرسال...' : 'إرسال رمز التحقق',
                  onPressed: _loading ? null : _submit,
                ),
                const SizedBox(height: 17),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(
                    'العودة لتسجيل الدخول',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  style: TextButton.styleFrom(foregroundColor: AppColors.forestDark),
                ),
                const SizedBox(height: 16),
                const _RecoveryBottomGarden(),
              ],
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
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 62,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const AppLogo(size: 56),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.forestDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _RecoveryHero(compact: true),
                const SizedBox(height: 14),
                const Text(
                  'إعادة تعيين كلمة المرور',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (widget.email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'تم إرسال رمز الاستعادة إلى ${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
                  ),
                ],
                const SizedBox(height: 22),
                _RecoveryFieldShell(
                  child: TextField(
                    controller: _token,
                    decoration: const InputDecoration(
                      hintText: 'رمز الاستعادة',
                      prefixIcon: Icon(Icons.key_rounded, color: AppColors.forestDark),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _RecoveryFieldShell(
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'كلمة المرور الجديدة',
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.forestDark),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _RecoveryFieldShell(
                  child: TextField(
                    controller: _confirm,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'تأكيد كلمة المرور',
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.forestDark),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 18),
                _RecoveryGradientButton(
                  label: _loading ? 'جاري التحديث...' : 'تحديث كلمة المرور',
                  onPressed: _loading ? null : _reset,
                ),
              ],
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
        height: 59,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFE3DDCD)),
          boxShadow: const [
            BoxShadow(color: Color(0x0C000000), blurRadius: 13, offset: Offset(0, 4)),
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
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0B4B2A), Color(0xFF1D6A3E)],
          ),
          borderRadius: BorderRadius.circular(21),
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
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
                child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .16), size: 28),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
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
    final height = compact ? 150.0 : 215.0;
    final circle = compact ? 126.0 : 174.0;
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
            bottom: 20,
            start: compact ? 70 : 58,
            child: Transform.rotate(
              angle: -.42,
              child: const Icon(Icons.eco_rounded, color: Color(0xFF5B814D), size: 78),
            ),
          ),
          PositionedDirectional(
            bottom: 22,
            end: compact ? 72 : 55,
            child: Transform.rotate(
              angle: .42,
              child: const Icon(Icons.eco_rounded, color: Color(0xFF77945F), size: 74),
            ),
          ),
          Container(
            width: compact ? 84 : 108,
            height: compact ? 92 : 118,
            decoration: BoxDecoration(
              color: const Color(0xFF1D663D),
              borderRadius: BorderRadius.circular(compact ? 22 : 27),
              boxShadow: const [BoxShadow(color: Color(0x180D4328), blurRadius: 16, offset: Offset(0, 5))],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.lock_rounded, color: const Color(0xFFF9F1D7), size: compact ? 49 : 64),
          ),
          Positioned(
            top: compact ? 21 : 24,
            child: Container(
              width: compact ? 49 : 66,
              height: compact ? 56 : 72,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.terracotta, width: compact ? 8 : 10),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: compact ? 26 : 35,
            end: compact ? 56 : 43,
            child: const Icon(Icons.circle, color: AppColors.terracotta, size: 11),
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
        height: 190,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            PositionedDirectional(
              bottom: -26,
              start: -32,
              child: Transform.rotate(
                angle: -.28,
                child: Icon(Icons.eco_rounded, size: 150, color: const Color(0xFF5D8050).withValues(alpha: .65)),
              ),
            ),
            PositionedDirectional(
              bottom: -26,
              end: -32,
              child: Transform.rotate(
                angle: .30,
                child: Icon(Icons.eco_rounded, size: 150, color: const Color(0xFF5D8050).withValues(alpha: .62)),
              ),
            ),
            PositionedDirectional(
              bottom: 28,
              start: 31,
              child: Icon(Icons.circle, color: AppColors.terracotta.withValues(alpha: .78), size: 14),
            ),
            PositionedDirectional(
              bottom: 34,
              end: 35,
              child: Icon(Icons.circle, color: AppColors.terracotta.withValues(alpha: .72), size: 13),
            ),
          ],
        ),
      );
}
