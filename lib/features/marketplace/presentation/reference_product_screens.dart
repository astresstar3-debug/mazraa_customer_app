import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'unified_product_details_screen.dart';

class ReferenceProductDetailsScreen extends StatelessWidget {
  const ReferenceProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) =>
      UnifiedProductDetailsScreen(product: product);
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${product.rating == 0 ? 4.8 : product.rating}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '(${product.reviews == 0 ? 126 : product.reviews} تقييم)',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPrice(product.price),
                style: const TextStyle(
                  color: AppColors.forest,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (product.oldPrice != null)
                Text(
                  formatPrice(product.oldPrice!),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
        ],
      );
}

class _StatusDataCard extends StatelessWidget {
  const _StatusDataCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            _InfoPill(
              icon: Icons.inventory_2_outlined,
              label: _kindLabel(product.kind),
              value: 'نوع المنتج',
            ),
            const _VerticalDivider(),
            _InfoPill(
              icon: Icons.check_circle_outline_rounded,
              label: product.inStock ? 'متوفر' : 'غير متوفر',
              value: 'الحالة',
              color: product.inStock ? AppColors.success : AppColors.error,
            ),
            const _VerticalDivider(),
            _InfoPill(
              icon: Icons.percent_rounded,
              label: '${product.discount ?? 0}%',
              value: 'الخصم',
              color: AppColors.terracotta,
            ),
          ],
        ),
      );
}

class _ProductMetaCard extends StatelessWidget {
  const _ProductMetaCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
        child: Column(
          children: [
            _MetaRow(
              icon: Icons.verified_outlined,
              title: 'الماركة',
              value: product.kind == ProductKind.medicine ? 'VetCare' : 'مزرعتي',
            ),
            const Divider(height: 16),
            _MetaRow(
              icon: Icons.category_outlined,
              title: 'القسم',
              value: product.category.isEmpty
                  ? 'منتجات زراعية'
                  : product.category,
            ),
            const Divider(height: 16),
            const _MetaRow(
              icon: Icons.local_shipping_outlined,
              title: 'التوصيل',
              value: 'متاح خلال 1-3 أيام',
            ),
          ],
        ),
      );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.forest, size: 19),
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
        ],
      );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.forest,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: AppColors.muted, fontSize: 8.5),
            ),
          ],
        ),
      );
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: AppColors.border,
      );
}

class _MedicineWarningCard extends StatelessWidget {
  const _MedicineWarningCard();

  @override
  Widget build(BuildContext context) => const AppSurfaceCard(
        color: AppColors.terracottaSoft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              color: AppColors.terracotta,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنبيه للاستخدام البيطري',
                    style: TextStyle(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'يُستخدم وفق الجرعة الموصى بها وتحت إشراف الطبيب البيطري.',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _FeedAttributesCard extends StatelessWidget {
  const _FeedAttributesCard();

  @override
  Widget build(BuildContext context) => const AppSurfaceCard(
        color: AppColors.forestSoft,
        child: Row(
          children: [
            Expanded(child: _SmallMetric('البروتين', '18%')),
            Expanded(child: _SmallMetric('الوزن', '50 كجم')),
            Expanded(child: _SmallMetric('النوع', 'مواشي')),
          ],
        ),
      );
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.forestDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
          ),
        ],
      );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => onChanged(value >= 99 ? 99 : value + 1),
              icon: const Icon(Icons.add_rounded),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(
              width: 36,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              onPressed: () => onChanged(value <= 1 ? 1 : value - 1),
              icon: const Icon(Icons.remove_rounded),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
}

class _ProductTabs extends StatelessWidget {
  const _ProductTabs({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const names = ['الوصف', 'المواصفات', 'الأسئلة', 'التقييمات'];
    return Row(
      children: List.generate(
        names.length,
        (index) => Expanded(
          child: InkWell(
            onTap: () => onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: value == index
                        ? AppColors.forest
                        : AppColors.border,
                    width: value == index ? 3 : 1,
                  ),
                ),
              ),
              child: Text(
                names[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: value == index
                      ? AppColors.forest
                      : AppColors.muted,
                  fontSize: 11,
                  fontWeight: value == index
                      ? FontWeight.w900
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductTabBody extends StatelessWidget {
  const _ProductTabBody({required this.product, required this.tab});

  final Product product;
  final int tab;

  @override
  Widget build(BuildContext context) {
    if (tab == 1) {
      return const AppSurfaceCard(
        child: Column(
          children: [
            _MetaRow(
              icon: Icons.straighten_rounded,
              title: 'الوزن/الحجم',
              value: 'حسب العبوة',
            ),
            Divider(height: 16),
            _MetaRow(
              icon: Icons.public_rounded,
              title: 'بلد المنشأ',
              value: 'المملكة العربية السعودية',
            ),
            Divider(height: 16),
            _MetaRow(
              icon: Icons.inventory_outlined,
              title: 'التخزين',
              value: 'مكان جاف وبارد',
            ),
          ],
        ),
      );
    }

    if (tab == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل المنتج مناسب للاستخدام اليومي؟',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'نعم، مع اتباع تعليمات الاستخدام المرفقة.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/ask-question'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('اطرح سؤالًا'),
          ),
        ],
      );
    }

    if (tab == 3) {
      return AppSurfaceCard(
        child: Row(
          children: [
            const Column(
              children: [
                Text(
                  '4.8',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.forestDark,
                  ),
                ),
                Text(
                  '★★★★★',
                  style: TextStyle(color: AppColors.warning),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(5, (index) {
                  final stars = 5 - index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Text('$stars', style: const TextStyle(fontSize: 9)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: stars / 5,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      product.description.isEmpty
          ? 'منتج مختار بعناية من متجر مزرعتي، بجودة موثوقة ومواصفات مناسبة للاستخدام الزراعي والبيطري.'
          : product.description,
      style: const TextStyle(height: 1.8, fontSize: 12.5),
    );
  }
}

class _SimilarProducts extends StatelessWidget {
  const _SimilarProducts({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final visible = products.take(4).toList();
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = visible[index];
          return SizedBox(
            width: 135,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReferenceProductDetailsScreen(product: item),
                ),
              ),
              child: AppSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: AppDataImage(item.image, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            formatPrice(item.price),
                            style: const TextStyle(
                              color: AppColors.forest,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReferenceReviewsQuestionsScreen extends StatefulWidget {
  const ReferenceReviewsQuestionsScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ReferenceReviewsQuestionsScreen> createState() =>
      _ReferenceReviewsQuestionsScreenState();
}

class _ReferenceReviewsQuestionsScreenState
    extends State<ReferenceReviewsQuestionsScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const MazraaAppBar(title: 'التقييمات والأسئلة'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 96,
                        height: 76,
                        child: AppDataImage(
                          widget.product.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Row(
                            children: [
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                '★★★★★',
                                style: TextStyle(color: AppColors.warning),
                              ),
                            ],
                          ),
                          const Text(
                            '126 تقييم',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProductTabs(
                value: tab,
                onChanged: (value) => setState(() => tab = value),
              ),
              const SizedBox(height: 12),
              if (tab == 2)
                _QuestionsList(product: widget.product)
              else
                _ReviewsList(product: widget.product),
            ],
          ),
        ),
      );
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Column(
        children: const [
          _ReviewCard(
            name: 'أم محمد',
            text: 'جودة ممتازة والتغليف أنيق ووصل المنتج في الموعد.',
          ),
          SizedBox(height: 9),
          _ReviewCard(
            name: 'سالم المطيري',
            text: 'منتج مطابق للوصف وسأكرر الشراء مرة أخرى.',
          ),
          SizedBox(height: 9),
          _ReviewCard(
            name: 'نورة القحطاني',
            text: 'تجربة جيدة وخدمة سريعة من البائع.',
          ),
        ],
      );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.forestSoft,
                  child: Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const Text(
                  '★★★★★',
                  style: TextStyle(color: AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      );
}

class _QuestionsList extends StatelessWidget {
  const _QuestionsList({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل يتوفر المنتج بأكثر من حجم؟',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  'نعم، تتوفر عدة خيارات حسب المخزون الحالي.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/ask-question'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('اسأل عن هذا المنتج'),
          ),
        ],
      );
}

class ReferenceAskQuestionScreen extends StatelessWidget {
  const ReferenceAskQuestionScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const MazraaAppBar(title: 'سؤال عن المنتج'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 82,
                        height: 68,
                        child: AppDataImage(product.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.forestDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 7,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'اكتب سؤالك بالتفصيل هنا...',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'أسئلة مقترحة',
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  Chip(label: Text('ما مدة الصلاحية؟')),
                  Chip(label: Text('هل يوجد توصيل سريع؟')),
                  Chip(label: Text('هل يناسب الاستخدام اليومي؟')),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.send_rounded),
                label: const Text('إرسال السؤال'),
              ),
            ],
          ),
        ),
      );
}

String _kindLabel(ProductKind kind) => switch (kind) {
      ProductKind.crop => 'زراعي',
      ProductKind.animal => 'حيواني',
      ProductKind.supply => 'مستلزمات',
      ProductKind.medicine => 'دواء بيطري',
      ProductKind.feed => 'علف',
    };
