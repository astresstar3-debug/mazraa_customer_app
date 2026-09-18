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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 760;
              return SingleChildScrollView(
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
                        child: _AuthLandscape(height: 202),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(22, compact ? 10 : 20, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(child: AppLogo(size: compact ? 114 : 132, showName: true)),
                            SizedBox(height: compact ? 16 : 28),
                            const Text(
                              'أهلاً بك في مزرعتي',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.forestDark,
                                fontSize: 31,
                                height: 1.22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'تسوق وشارك في المزادات بثقة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF687563),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: compact ? 24 : 34),
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
                            const SizedBox(height: 16),
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
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsetsDirectional.fromSTEB(4, 11, 4, 11),
                                ),
                                child: const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    color: AppColors.forestDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            _AuthGradientButton(
                              label: 'تسجيل الدخول',
                              loading: loading,
                              onPressed: _login,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: Color(0xFFB8BDAA), thickness: .8)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14),
                                    child: Text('أو', style: TextStyle(color: Color(0xFF7A856F), fontSize: 14)),
                                  ),
                                  Expanded(child: Divider(color: Color(0xFFB8BDAA), thickness: .8)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 62,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/register'),
                                icon: const Icon(Icons.person_add_alt_1_rounded, size: 25),
                                label: const Text(
                                  'إنشاء حساب جديد',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.forestDark,
                                  side: const BorderSide(color: AppColors.forest, width: 1.35),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_rounded, color: AppColors.forest, size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'سلة التسوق والمفضلة محفوظة لحسابك.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFF66745E), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 145 : 190),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
  bool obscurePassword = true;
  bool obscureConfirm = true;

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
                      child: _AuthLandscape(height: 190),
                    ),
                    const PositionedDirectional(
                      top: 100,
                      end: -25,
                      child: _CornerLeaves(),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(22, 6, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 86,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const AppLogo(size: 80),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    onPressed: () => Navigator.maybePop(context),
                                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark, size: 29),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'إنشاء حساب جديد',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 30,
                              height: 1.2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'أنشئ حسابك وابدأ التسوق والمزايدة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF687563), fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 34),
                          _AuthFieldShell(
                            child: TextField(
                              controller: nameController,
                              decoration: _authDecoration(hint: 'الاسم الكامل', icon: Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _AuthFieldShell(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _authDecoration(hint: 'رقم الجوال', icon: Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _AuthFieldShell(
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _authDecoration(hint: 'البريد الإلكتروني', icon: Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _AuthFieldShell(
                            child: TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: _authDecoration(
                                hint: 'كلمة المرور',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                  icon: Icon(
                                    obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFF64735C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _AuthFieldShell(
                            child: TextField(
                              controller: confirmController,
                              obscureText: obscureConfirm,
                              decoration: _authDecoration(
                                hint: 'تأكيد كلمة المرور',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                                  icon: Icon(
                                    obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFF64735C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          Row(
                            children: [
                              Checkbox(
                                value: accepted,
                                onChanged: (value) => setState(() => accepted = value ?? false),
                                activeColor: AppColors.forest,
                                side: const BorderSide(color: AppColors.forestDark, width: 1.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/legal'),
                                  child: const Text(
                                    'أوافق على الشروط وسياسة الخصوصية',
                                    style: TextStyle(
                                      color: AppColors.forestDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _AuthGradientButton(
                            label: 'إنشاء الحساب',
                            loading: loading,
                            onPressed: _register,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: Color(0xFFD1CDBD))),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Icon(Icons.eco_rounded, color: AppColors.forest, size: 21),
                                ),
                                Expanded(child: Divider(color: Color(0xFFD1CDBD))),
                              ],
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'لدي حساب بالفعل  ',
                                      style: TextStyle(color: Color(0xFF7E8776), fontSize: 13),
                                    ),
                                    TextSpan(
                                      text: 'تسجيل الدخول',
                                      style: TextStyle(
                                        color: AppColors.forestDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 150),
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

class _AuthFieldShell extends StatelessWidget {
  const _AuthFieldShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1DACA), width: 1.05),
          boxShadow: const [
            BoxShadow(color: Color(0x0E000000), blurRadius: 14, offset: Offset(0, 5)),
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
      hintStyle: const TextStyle(color: Color(0xFF8C8D7B), fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: AppColors.forestDark, size: 24),
      suffixIcon: suffix,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: false,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 17),
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
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0A4728), Color(0xFF226A3D)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Color(0x160D4328), blurRadius: 17, offset: Offset(0, 7)),
          ],
        ),
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    PositionedDirectional(
                      start: 8,
                      child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .17), size: 31),
                    ),
                    PositionedDirectional(
                      end: 8,
                      child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .14), size: 29),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      );
}

class _CornerLeaves extends StatelessWidget {
  const _CornerLeaves();

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -.4,
        child: Column(
          children: [
            Icon(Icons.eco_rounded, size: 74, color: const Color(0xFF719151).withValues(alpha: .58)),
            Transform.translate(
              offset: const Offset(-28, -20),
              child: Icon(Icons.eco_rounded, size: 40, color: const Color(0xFF91AA6C).withValues(alpha: .56)),
            ),
          ],
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
              bottom: -8,
              start: -24,
              child: Transform.rotate(
                angle: -.24,
                child: Icon(
                  Icons.eco_rounded,
                  size: height * .77,
                  color: const Color(0xFF5F7D49).withValues(alpha: .68),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 11,
              start: height * .20,
              child: Column(
                children: [
                  Icon(Icons.circle, size: 17, color: AppColors.terracotta.withValues(alpha: .78)),
                  const SizedBox(height: 8),
                  Icon(Icons.circle, size: 12, color: AppColors.terracotta.withValues(alpha: .62)),
                ],
              ),
            ),
            PositionedDirectional(
              bottom: 16,
              end: 28,
              child: Icon(Icons.home_rounded, size: height * .25, color: const Color(0xFFC86C37).withValues(alpha: .82)),
            ),
            PositionedDirectional(
              bottom: 12,
              end: 2,
              child: Icon(Icons.park_rounded, size: height * .32, color: const Color(0xFF718B55).withValues(alpha: .70)),
            ),
          ],
        ),
      );
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final pale = Paint()..color = const Color(0xFFE9E1B4).withValues(alpha: .75);
    final green = Paint()..color = const Color(0xFF9FAF7A).withValues(alpha: .66);
    final cream = Paint()..color = const Color(0xFFF2E6C6).withValues(alpha: .94);
    final white = Paint()..color = AppColors.ivory.withValues(alpha: .96);

    final p1 = Path()
      ..moveTo(0, size.height * .65)
      ..quadraticBezierTo(size.width * .22, size.height * .43, size.width * .48, size.height * .67)
      ..quadraticBezierTo(size.width * .75, size.height * .91, size.width, size.height * .56)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, cream);

    final p2 = Path()
      ..moveTo(size.width * .45, size.height)
      ..quadraticBezierTo(size.width * .69, size.height * .58, size.width, size.height * .68)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(p2, green);

    final p3 = Path()
      ..moveTo(0, size.height * .84)
      ..quadraticBezierTo(size.width * .30, size.height * .67, size.width * .58, size.height * .84)
      ..quadraticBezierTo(size.width * .80, size.height * .94, size.width, size.height * .78)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p3, pale);

    final lane = Path()
      ..moveTo(size.width * .58, size.height)
      ..quadraticBezierTo(size.width * .70, size.height * .80, size.width * .89, size.height * .72)
      ..quadraticBezierTo(size.width * .78, size.height * .92, size.width * .71, size.height);
    canvas.drawPath(lane, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
