import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';

class ConnectedServerProductQuestionsScreen extends StatefulWidget {
  const ConnectedServerProductQuestionsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ConnectedServerProductQuestionsScreen> createState() =>
      _ConnectedServerProductQuestionsScreenState();
}

class _ConnectedServerProductQuestionsScreenState
    extends State<ConnectedServerProductQuestionsScreen> {
  final questionController = TextEditingController();
  bool loading = true;
  bool sending = false;
  String? error;
  List<Map<String, dynamic>> questions = const [];

  int? get productId => int.tryParse(widget.product.id);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading && questions.isEmpty && error == null) _load();
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = productId;
    if (id == null) {
      setState(() {
        loading = false;
        error = 'رقم المنتج غير صالح.';
      });
      return;
    }
    try {
      final response = await AppScope.of(context).client.get('/api/products/$id/questions');
      if (!mounted) return;
      setState(() {
        questions = response is List
            ? response.map((e) => jsonMap(e)).toList()
            : const [];
      });
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر تحميل الأسئلة.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _send() async {
    final app = AppScope.of(context);
    if (!app.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final id = productId;
    final text = questionController.text.trim();
    if (id == null || text.isEmpty) return;
    setState(() {
      sending = true;
      error = null;
    });
    try {
      await app.client.post('/api/products/$id/questions', body: {
        'question': text,
      });
      questionController.clear();
      setState(() => loading = true);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال السؤال بنجاح')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر إرسال السؤال.');
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'أسئلة المنتج'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AppDataImage(
                        widget.product.image,
                        width: 78,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: questionController,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'اكتب سؤالك عن المنتج',
                  prefixIcon: Icon(Icons.help_outline_rounded),
                ),
              ),
              FilledButton.icon(
                onPressed: sending ? null : _send,
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: const Text('إرسال السؤال'),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 16),
              const SectionHeader(
                title: 'الأسئلة والإجابات',
                icon: Icons.forum_outlined,
              ),
              if (loading)
                const LinearProgressIndicator()
              else if (questions.isEmpty)
                const AppSurfaceCard(
                  child: Text('لا توجد أسئلة لهذا المنتج حتى الآن.'),
                )
              else
                ...questions.map((item) {
                  final question = '${jsonValue(item, 'question') ?? ''}';
                  final answer = '${jsonValue(item, 'answer') ?? ''}';
                  final user = '${jsonValue(item, 'userName') ?? ''}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.help_center_outlined,
                                  color: AppColors.forest),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  question,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          if (user.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(user,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted)),
                          ],
                          const SizedBox(height: 8),
                          if (answer.trim().isEmpty)
                            const Text('بانتظار إجابة المتجر.',
                                style: TextStyle(color: AppColors.muted))
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.forestSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(answer),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      );
}
