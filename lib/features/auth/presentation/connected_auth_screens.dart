import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../account/data/account_repository.dart';

class ConnectedLoginScreen extends StatefulWidget {
  const ConnectedLoginScreen({super.key});

  @override
  State<ConnectedLoginScreen> createState() => _ConnectedLoginScreenState();
}

class _ConnectedLoginScreenState extends State<ConnectedLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل البريد الإلكتروني وكلمة المرور')),
      );
      return;
    }
    setState(() => loading = true);
    final app = AppScope.of(context);
    try {
      await app.login(email, password);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.errorMessage ?? 'تعذر تسجيل الدخول')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                const Center(child: AppLogo(size: 105, showName: true)),
                const SizedBox(height: 24),
                const Text(
                  'أهلاً بك في مزرعتي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 29,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'تسوق وشارك في المزادات بثقة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                _AuthFieldShell(
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _authDecoration(
                      hint: 'رقم الجوال أو البريد الإلكتروني',
                      icon: Icons.email_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                _AuthFieldShell(
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    onSubmitted: (_) {
                      if (!loading) _login();
                    },
                    decoration: _authDecoration(
                      hint: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF78836F),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                _AuthGradientButton(
                  label: 'تسجيل الدخول',
                  loading: loading,
                  onPressed: _login,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 17),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFBFC3AD))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        child: Text('أو', style: TextStyle(color: AppColors.muted)),
                      ),
                      Expanded(child: Divider(color: Color(0xFFBFC3AD))),
                    ],
                  ),
                ),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forestDark,
                      side: const BorderSide(color: AppColors.forest, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded, color: AppColors.forest, size: 16),
                    SizedBox(width: 7),
                    Text(
                      'سلة التسوق والمفضلة محفوظة لحسابك.',
                      style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _AuthLandscape(height: 178),
              ],
            ),
          ),
        ),
      );
}

class ConnectedRegisterScreen extends StatefulWidget {
  const ConnectedRegisterScreen({super.key});

  @override
  State<ConnectedRegisterScreen> createState() => _ConnectedRegisterScreenState();
}

class _ConnectedRegisterScreenState extends State<ConnectedRegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool accepted = true;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    if (name.isEmpty || email.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل الحقول المطلوبة')));
      return;
    }
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمتا المرور غير متطابقتين')));
      return;
    }
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب الموافقة على الشروط وسياسة الخصوصية')));
      return;
    }

    setState(() => loading = true);
    final app = AppScope.of(context);
    try {
      await app.register(name: name, email: email, password: passwordController.text);
      await AccountRepository(app.client).updateProfile(name: name, email: email, phone: phone);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/location-permission', (_) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.errorMessage ?? 'تعذر إنشاء الحساب')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 8, 18, 0),
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
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark, size: 26),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 27,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 9),
                    Icon(Icons.eco_rounded, color: AppColors.forest, size: 23),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'أنشئ حسابك وابدأ التسوق والمزايدة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                ),
                const SizedBox(height: 23),
                _AuthFieldShell(
                  child: TextField(
                    controller: nameController,
                    decoration: _authDecoration(hint: 'الاسم الكامل', icon: Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 11),
                _AuthFieldShell(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _authDecoration(hint: 'رقم الجوال', icon: Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 11),
                _AuthFieldShell(
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _authDecoration(hint: 'البريد الإلكتروني', icon: Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 11),
                _AuthFieldShell(
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: _authDecoration(
                      hint: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      suffix: const Icon(Icons.visibility_outlined, color: Color(0xFF78836F)),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                _AuthFieldShell(
                  child: TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: _authDecoration(
                      hint: 'تأكيد كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      suffix: const Icon(Icons.visibility_outlined, color: Color(0xFF78836F)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: accepted,
                      onChanged: (value) => setState(() => accepted = value ?? false),
                      activeColor: AppColors.forest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/legal'),
                        child: const Text(
                          'أوافق على الشروط وسياسة الخصوصية',
                          style: TextStyle(
                            color: AppColors.forestDark,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _AuthGradientButton(
                  label: 'إنشاء الحساب',
                  loading: loading,
                  onPressed: _register,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFD8D2C0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.eco_rounded, color: AppColors.forest, size: 20),
                      ),
                      Expanded(child: Divider(color: Color(0xFFD8D2C0))),
                    ],
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'لدي حساب بالفعل  ', style: TextStyle(color: AppColors.muted)),
                          TextSpan(
                            text: 'تسجيل الدخول',
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const _AuthLandscape(height: 132),
              ],
            ),
          ),
        ),
      );
}

class _AuthFieldShell extends StatelessWidget {
  const _AuthFieldShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFE4DECF)),
          boxShadow: const [
            BoxShadow(color: Color(0x0B000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

InputDecoration _authDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8A8A79), fontSize: 12.5),
      prefixIcon: Icon(icon, color: AppColors.forestDark, size: 22),
      suffixIcon: suffix,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: false,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 18, 14, 15),
    );

class _AuthGradientButton extends StatelessWidget {
  const _AuthGradientButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0B4D2B), Color(0xFF1D6B3E)],
          ),
          borderRadius: BorderRadius.circular(21),
          boxShadow: const [
            BoxShadow(color: Color(0x140D4328), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    PositionedDirectional(
                      start: 3,
                      child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .20), size: 26),
                    ),
                    PositionedDirectional(
                      end: 3,
                      child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .16), size: 26),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      );
}

class _AuthLandscape extends StatelessWidget {
  const _AuthLandscape({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _LandscapePainter())),
            PositionedDirectional(
              bottom: -5,
              start: -15,
              child: Transform.rotate(
                angle: -.28,
                child: Icon(Icons.eco_rounded, size: height * .78, color: const Color(0xFF6F8D58).withValues(alpha: .55)),
              ),
            ),
            PositionedDirectional(
              bottom: 3,
              end: 6,
              child: Transform.rotate(
                angle: .35,
                child: Icon(Icons.eco_rounded, size: height * .46, color: const Color(0xFF91A66D).withValues(alpha: .48)),
              ),
            ),
            PositionedDirectional(
              bottom: height * .16,
              start: height * .20,
              child: Icon(Icons.circle, size: 13, color: AppColors.terracotta.withValues(alpha: .58)),
            ),
          ],
        ),
      );
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final pale = Paint()..color = const Color(0xFFE9E1B4).withValues(alpha: .64);
    final green = Paint()..color = const Color(0xFFB8C395).withValues(alpha: .58);
    final cream = Paint()..color = const Color(0xFFF2E8C9).withValues(alpha: .90);

    final p1 = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(size.width * .24, size.height * .48, size.width * .51, size.height * .69)
      ..quadraticBezierTo(size.width * .78, size.height * .90, size.width, size.height * .62)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, cream);

    final p2 = Path()
      ..moveTo(size.width * .37, size.height)
      ..quadraticBezierTo(size.width * .65, size.height * .62, size.width, size.height * .70)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(p2, green);

    final p3 = Path()
      ..moveTo(0, size.height * .87)
      ..quadraticBezierTo(size.width * .28, size.height * .70, size.width * .58, size.height * .86)
      ..quadraticBezierTo(size.width * .80, size.height * .96, size.width, size.height * .80)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p3, pale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
