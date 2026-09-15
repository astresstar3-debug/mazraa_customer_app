import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../account/data/customer_service_repository.dart';
import '../domain/marketplace_models.dart';

class ConnectedProductReviewsScreen extends StatefulWidget {
  const ConnectedProductReviewsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ConnectedProductReviewsScreen> createState() =>
      _ConnectedProductReviewsScreenState();
}

class _ConnectedProductReviewsScreenState
    extends State<ConnectedProductReviewsScreen> {
  bool _loading = true;
  String? _error;
  List<ProductReviewData> _reviews = const [];

  CustomerServiceRepository get _repository =>
      CustomerServiceRepository(AppScope.of(context).client);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _reviews.isEmpty && _error == null) _load();
  }

  Future<void> _load() async {
    final productId = int.tryParse(widget.product.id);
    if (productId == null) {
      setState(() {
        _error = 'رقم المنتج غير صالح.';
        _loading = false;
      });
      return;
    }
    try {
      final items = await _repository.fetchProductReviews(productId);
      if (mounted) setState(() => _reviews = items);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تحميل تقييمات المنتج.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openReviewForm() async {
    if (!AppScope.of(context).isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ConnectedCreateProductReviewScreen(
          product: widget.product,
        ),
      ),
    );
    if (changed == true && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'التقييمات'),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: _openReviewForm,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('إضافة تقييم'),
            ),
          ),
        ),
        body: AppPage(
          child: Column(
            children: [
              AppSurfaceCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppDataImage(
                        widget.product.image,
                        width: 100,
                        height: 78,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              Text(
                                '${widget.product.rating}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFE5A72D)),
                            ],
                          ),
                          Text('${_reviews.length} تقييم من الخادم'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const LinearProgressIndicator()
              else if (_error != null)
                ResultStateView(
                  kind: ResultKind.error,
                  title: 'تعذر تحميل التقييمات',
                  message: _error!,
                  primaryLabel: 'إعادة المحاولة',
                  onPrimary: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _load();
                  },
                )
              else if (_reviews.isEmpty)
                const ResultStateView(
                  kind: ResultKind.empty,
                  title: 'لا توجد تقييمات بعد',
                  message: 'سيظهر هنا ما يرسله العملاء بعد استلام طلباتهم.',
                )
              else
                ..._reviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.forestSoft,
                                child: Text(
                                  review.userName.trim().isEmpty
                                      ? '؟'
                                      : review.userName.trim()[0],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  review.userName.trim().isEmpty
                                      ? 'مستخدم'
                                      : review.userName,
                                  style:
                                      Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < review.rating.round()
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 17,
                                    color: const Color(0xFFE5A72D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (review.title.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              review.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                          if (review.text.trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(review.text),
                          ],
                          if (review.createdAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _date(review.createdAt!),
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class ConnectedCreateProductReviewScreen extends StatefulWidget {
  const ConnectedCreateProductReviewScreen({super.key, required this.product});
  final Product product;

  @override
  State<ConnectedCreateProductReviewScreen> createState() =>
      _ConnectedCreateProductReviewScreenState();
}

class _ConnectedCreateProductReviewScreenState
    extends State<ConnectedCreateProductReviewScreen> {
  int rating = 5;
  final _title = TextEditingController();
  final _text = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final productId = int.tryParse(widget.product.id);
    if (productId == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CustomerServiceRepository(AppScope.of(context).client)
          .createProductReview(
        productId: productId,
        rating: rating.toDouble(),
        title: _title.text,
        text: _text.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال تقييم المنتج')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is ApiException
          ? error.message
          : 'تعذر إرسال التقييم.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'تقييم المنتج'),
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
                        width: 82,
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
              const SizedBox(height: 16),
              AppSurfaceCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () => setState(() => rating = index + 1),
                      icon: Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFE5A72D),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'عنوان التقييم'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _text,
                maxLines: 5,
                maxLength: 1000,
                decoration:
                    const InputDecoration(labelText: 'اكتب تجربتك مع المنتج'),
              ),
              const AppSurfaceCard(
                color: AppColors.forestSoft,
                child: Text(
                  'السيرفر يقبل تقييم المنتج فقط بعد شراء المنتج واستلام الطلب.',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 15),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.send_rounded),
                label: Text(_saving ? 'جاري الإرسال...' : 'إرسال التقييم'),
              ),
            ],
          ),
        ),
      );
}

class ConnectedProductQuestionsScreen extends StatelessWidget {
  const ConnectedProductQuestionsScreen({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'الأسئلة'),
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
                        product.image,
                        width: 82,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(product.name,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const ResultStateView(
                kind: ResultKind.empty,
                title: 'الأسئلة غير متاحة من الخادم حاليًا',
                message:
                    'لا يوجد في نسخة السيرفر الحالية endpoint لأسئلة المنتجات، لذلك لن يعرض التطبيق أسئلة أو نجاحات وهمية.',
              ),
            ],
          ),
        ),
      );
}

String _date(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)}';
}
