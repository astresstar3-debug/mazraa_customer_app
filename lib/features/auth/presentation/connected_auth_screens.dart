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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.forest),
              ),
              const Text(
                'تسوق وشارك في المزادات بثقة',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                onSubmitted: (_) => loading ? null : _login(),
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text('نسيت كلمة المرور؟'),
                ),
              ),
              FilledButton(
                onPressed: loading ? null : _login,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('تسجيل الدخول'),
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

class ConnectedRegisterScreen extends StatefulWidget {
  const ConnectedRegisterScreen({super.key});

  @override
  State<ConnectedRegisterScreen> createState() =>
      _ConnectedRegisterScreenState();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل الحقول المطلوبة')),
      );
      return;
    }
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط وسياسة الخصوصية')),
      );
      return;
    }

    setState(() => loading = true);
    final app = AppScope.of(context);
    try {
      await app.register(
        name: name,
        email: email,
        password: passwordController.text,
      );
      // The current register endpoint creates the account with an empty phone.
      // Persist the phone immediately through the authenticated profile API.
      await AccountRepository(app.client).updateProfile(
        name: name,
        email: email,
        phone: phone,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/location-permission',
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.errorMessage ?? 'تعذر إنشاء الحساب')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إنشاء حساب جديد',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.forest),
              ),
              const Text(
                'أنشئ حسابًا وابدأ التسوق والمزايدة',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              CheckboxListTile(
                value: accepted,
                onChanged: (value) =>
                    setState(() => accepted = value ?? false),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'أوافق على الشروط وسياسة الخصوصية',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              FilledButton(
                onPressed: loading ? null : _register,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('إنشاء الحساب'),
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
