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
        appBar: const MazraaAppBar(title: 'نسيت كلمة المرور'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.forestSoft,
                  child: Icon(Icons.lock_reset_rounded,
                      size: 56, color: AppColors.forest),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'استعادة كلمة المرور',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.forest),
              ),
              const SizedBox(height: 6),
              const Text(
                'أدخل بريد حسابك وسيرسل الخادم رمز الاستعادة إلى البريد.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: const Icon(Icons.mark_email_read_outlined),
                label: Text(_loading ? 'جاري الإرسال...' : 'إرسال رمز الاستعادة'),
              ),
            ],
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
        appBar: const MazraaAppBar(title: 'إعادة تعيين كلمة المرور'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.email.isNotEmpty)
                AppSurfaceCard(
                  color: AppColors.forestSoft,
                  child: Text(
                    'تم إرسال رمز الاستعادة إلى ${widget.email}',
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _token,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'رمز الاستعادة',
                  prefixIcon: Icon(Icons.key_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _loading ? null : _reset,
                child: Text(_loading ? 'جاري التحديث...' : 'تحديث كلمة المرور'),
              ),
            ],
          ),
        ),
      );
}
