import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class ConnectedDeleteAccountScreen extends StatefulWidget {
  const ConnectedDeleteAccountScreen({super.key});

  @override
  State<ConnectedDeleteAccountScreen> createState() =>
      _ConnectedDeleteAccountScreenState();
}

class _ConnectedDeleteAccountScreenState
    extends State<ConnectedDeleteAccountScreen> {
  final _password = TextEditingController();
  bool _accepted = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_accepted) {
      setState(() => _error = 'أكد فهمك لنتيجة حذف الحساب أولًا.');
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _error = 'أدخل كلمة مرور الحساب للتأكيد.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final app = AppScope.of(context);
    try {
      await app.client.delete('/api/users/me', body: {
        'password': _password.text,
      });
      app.clearLocalSession();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الحساب.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is ApiException
          ? error.message
          : 'تعذر حذف الحساب.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'حذف الحساب'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Color(0xFFFFECE8),
                  child: Icon(Icons.person_remove_outlined,
                      size: 58, color: AppColors.error),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'حذف الحساب نهائيًا',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              const AppSurfaceCard(
                child: Text(
                  'سيطلب الخادم كلمة المرور، وقد يرفض الحذف إذا كان لديك طلب نشط. لا يتم عرض نجاح إلا بعد قبول الخادم للعملية.',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              CheckboxListTile(
                value: _accepted,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    setState(() => _accepted = value ?? false),
                title: const Text('أفهم أن حذف الحساب إجراء نهائي.'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: _loading ? null : _delete,
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(_loading ? 'جاري الحذف...' : 'حذف الحساب'),
              ),
            ],
          ),
        ),
      );
}
