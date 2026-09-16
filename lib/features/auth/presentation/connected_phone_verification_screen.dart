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
        appBar: const MazraaAppBar(title: 'التحقق من الهاتف'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.phonelink_lock_rounded,
                  size: 92, color: AppColors.forest),
              const SizedBox(height: 18),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: loading ? null : _send,
                icon: const Icon(Icons.sms_outlined),
                label: Text(sent ? 'إعادة إرسال الرمز' : 'إرسال رمز التحقق'),
              ),
              if (sent) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: code,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => loading ? null : _verify(),
                  decoration: const InputDecoration(
                    labelText: 'رمز التحقق',
                    prefixIcon: Icon(Icons.password_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: loading ? null : _verify,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: const Text('تحقق ومتابعة'),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: AppColors.error)),
              ],
            ],
          ),
        ),
      );
}
