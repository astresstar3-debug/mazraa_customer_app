import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();
  int page = 0;
  static const pages = [
    (
      'أهلًا بك في مزرعتي',
      'كل احتياجات مزرعتك في مكان واحد',
      Icons.agriculture_rounded,
    ),
    (
      'شارك في المزادات بثقة',
      'زايد على الحيوانات والمنتجات الزراعية والمعدات من بائعين موثوقين',
      Icons.gavel_rounded,
    ),
    (
      'تابع طلبك حتى يصل إليك',
      'توصيل موثوق وتتبع واضح من المزرعة إلى بابك',
      Icons.local_shipping_rounded,
    ),
  ];
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BotanicalBackdrop(
      dense: true,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const AppLogo(size: 58),
                  const Spacer(),
                  if (page < 2)
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('تخطي'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (value) => setState(() => page = value),
                itemCount: pages.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: i == 1
                                ? AppColors.terracottaSoft
                                : AppColors.forestSoft,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                pages[i].$3,
                                size: 180,
                                color: i == 1
                                    ? AppColors.terracotta
                                    : AppColors.forest,
                              ),
                              PositionedDirectional(
                                bottom: 38,
                                end: 35,
                                child: Icon(
                                  Icons.eco_rounded,
                                  size: 70,
                                  color: AppColors.forest.withValues(
                                    alpha: .35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        pages[i].$1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.forest),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pages[i].$2,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  width: i == page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == page ? AppColors.forest : AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (page < 2) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: Text(page < 2 ? 'التالي' : 'ابدأ الآن'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          const Center(child: AppLogo(size: 86, showName: true)),
          const SizedBox(height: 26),
          Text(
            'أهلًا بك في مزرعتي',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
          ),
          const Text(
            'تسوق وشارك في المزادات بثقة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'رقم الجوال أو البريد الإلكتروني',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 10),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: Icon(Icons.lock_outline_rounded),
              suffixIcon: Icon(Icons.visibility_off_outlined),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: const Text('نسيت كلمة المرور؟'),
            ),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            child: const Text('تسجيل الدخول'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('أو'),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('إنشاء حساب جديد'),
          ),
          const SizedBox(height: 18),
          const Text(
            'بيئة تسوق ومزايدة موثوقة وآمنة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إنشاء حساب جديد',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
          ),
          const Text(
            'أنشئ حسابًا وابدأ التسوق والمزايدة',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          const TextField(
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 9),
          const TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الجوال',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 9),
          const TextField(
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 9),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 9),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          CheckboxListTile(
            value: true,
            onChanged: (_) {},
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'أوافق على الشروط وسياسة الخصوصية',
              style: TextStyle(fontSize: 12),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/otp'),
            child: const Text('إنشاء الحساب'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لدي حساب بالفعل — تسجيل الدخول'),
          ),
        ],
      ),
    ),
  );
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.lock_reset_rounded,
            size: 150,
            color: AppColors.forest,
          ),
          const SizedBox(height: 20),
          Text(
            'هل نسيت كلمة المرور؟',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
          ),
          const Text(
            'أدخل رقم الجوال أو البريد الإلكتروني وسنرسل رمز التحقق',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني أو رقم الجوال',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/otp'),
            child: const Text('إرسال رمز التحقق'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('العودة لتسجيل الدخول'),
          ),
        ],
      ),
    ),
  );
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int seconds = 42;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && seconds > 0) setState(() => seconds--);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.phonelink_lock_rounded,
            size: 140,
            color: AppColors.forest,
          ),
          Text(
            'أدخل رمز التحقق',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
          ),
          const Text(
            'أرسلنا الرمز إلى +966 50 123 4567',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: List.generate(
                4,
                (i) => const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(counterText: ''),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'إعادة الإرسال خلال 00:${seconds.toString().padLeft(2, '0')}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.terracotta),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/location-permission',
              (_) => false,
            ),
            child: const Text('متابعة'),
          ),
          TextButton(onPressed: () {}, child: const Text('تغيير رقم الجوال')),
        ],
      ),
    ),
  );
}

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ResultStateView(
      kind: ResultKind.empty,
      title: 'فعّل موقعك',
      message: 'نستخدم موقعك لعرض المزادات القريبة وحساب تكلفة التوصيل بدقة',
      primaryLabel: 'السماح بالموقع',
      onPrimary: () => Navigator.pushReplacementNamed(context, '/location'),
      secondaryLabel: 'إدخال يدويًا',
      onSecondary: () => Navigator.pushReplacementNamed(context, '/location'),
    ),
  );
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تحديد الموقع'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSearchField(hint: 'ابحث عن موقع'),
          const SizedBox(height: 10),
          Container(
            height: 430,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE6D0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 430),
                  painter: _MapPainter(),
                ),
                const Icon(
                  Icons.location_on_rounded,
                  size: 74,
                  color: AppColors.forest,
                ),
                const PositionedDirectional(
                  top: 35,
                  end: 20,
                  child: StatusPill(label: 'حي النخيل'),
                ),
                const PositionedDirectional(
                  bottom: 30,
                  start: 20,
                  child: StatusPill(
                    label: 'وسط الرياض',
                    color: AppColors.terracotta,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('استخدام موقعي الحالي'),
          ),
          const SizedBox(height: 8),
          const AppSurfaceCard(
            child: ListTile(
              leading: Icon(Icons.location_on_rounded, color: AppColors.forest),
              title: Text('الرياض، حي النخيل، شارع الملك فهد'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              AppScope.of(context).setLocation('الرياض');
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            child: const Text('تأكيد الموقع'),
          ),
        ],
      ),
    ),
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: .8)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final y = 35.0 + i * 58;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (i.isEven ? 35 : -25)),
        road,
      );
    }
    for (var i = 0; i < 6; i++) {
      final x = 25.0 + i * 70;
      canvas.drawLine(Offset(x, 0), Offset(x + 45, size.height), road);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
