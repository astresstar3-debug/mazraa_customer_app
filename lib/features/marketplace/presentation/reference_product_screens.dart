import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';

class ReferenceProductDetailsScreen extends StatefulWidget {
  const ReferenceProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ReferenceProductDetailsScreen> createState() => _ReferenceProductDetailsScreenState();
}

class _ReferenceProductDetailsScreenState extends State<ReferenceProductDetailsScreen> {
  int quantity = 1;
  int selectedImage = 0;
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.images.isEmpty ? <String>[p.image, p.image, p.image] : p.images;
    final current = images[selectedImage.clamp(0, images.length - 1)];
    final app = AppScope.of(context);

    return Scaffold(
      appBar: MazraaAppBar(
        actions: [
          IconButton(
            onPressed: () => app.toggleFavorite(p.id),
            icon: Icon(app.isFavorite(p.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: app.isFavorite(p.id) ? AppColors.terracotta : AppColors.forestDark),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_rounded)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
                  onPressed: () async {
                    try {
                      await app.addToCart(p, quantity: quantity);
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: const Text('أضف إلى السلة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('اشترِ الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AppDataImage(current, fit: BoxFit.cover),
                  ),
                ),
                if ((p.discount ?? 0) > 0)
                  PositionedDirectional(
                    top: 10,
                    end: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(9)),
                      child: Text('خصم ${p.discount}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 61,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length.clamp(1, 4),
                separatorBuilder: (_, __) => const SizedBox(width: 7),
                itemBuilder: (_, index) => InkWell(
                  onTap: () => setState(() => selectedImage = index),
                  child: Container(
                    width: 74,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: selectedImage == index ? AppColors.forest : AppColors.border, width: selectedImage == index ? 2 : 1),
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: AppDataImage(images[index], fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(color: AppColors.forestDark, fontSize: 19, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                        const SizedBox(width: 3),
                        Text('${p.rating == 0 ? 4.8 : p.rating}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 5),
                        Text('(${p.reviews == 0 ? 126 : p.reviews} تقييم)', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatPrice(p.price), style: const TextStyle(color: AppColors.forest, fontSize: 20, fontWeight: FontWeight.w900)),
                    if (p.oldPrice != null)
                      Text(formatPrice(p.oldPrice!), style: const TextStyle(color: AppColors.muted, fontSize: 11, decoration: TextDecoration.lineThrough)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 13),
            _StatusDataCard(product: p),
            const SizedBox(height: 11),
            _ProductMetaCard(product: p),
            if (p.kind == ProductKind.medicine) ...[
              const SizedBox(height: 10),
              const _MedicineWarningCard(),
            ],
            if (p.kind == ProductKind.feed) ...[
              const SizedBox(height: 10),
              const _FeedAttributesCard(),
            ],
            const SizedBox(height: 13),
            Row(
              children: [
                const Text('الكمية', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.forestDark)),
                const Spacer(),
                _QuantityControl(value: quantity, onChanged: (value) => setState(() => quantity = value)),
              ],
            ),
            const SizedBox(height: 15),
            _Tabs(value: tab, onChanged: (value) => setState(() => tab = value)),
            const SizedBox(height: 12),
            _TabBody(product: p, tab: tab),
            const SizedBox(height: 20),
            const Row(children: [Icon(Icons.auto_awesome_rounded, color: AppColors.forest), SizedBox(width: 6), Text('منتجات مشابهة', style: TextStyle(color: AppColors.forestDark, fontSize: 17, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 9),
            SizedBox(
              height: 172,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: app.products.take(4).length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final item = app.products[index];
                  return SizedBox(
                    width: 135,
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReferenceProductDetailsScreen(product: item))),
                      child: AppSurfaceCard(
                        padding: EdgeInsets.zero,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: AppDataImage(item.image, fit: BoxFit.cover))),
                          Padding(padding: const EdgeInsets.all(7), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(formatPrice(item.price), style: const TextStyle(color: AppColors.forest, fontSize: 11, fontWeight: FontWeight.w900))])),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDataCard extends StatelessWidget {
  const _StatusDataCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            _InfoPill(icon: Icons.inventory_2_outlined, label: _kind(product.kind), value: 'نوع المنتج'),
            const _Divider(),
            _InfoPill(icon: Icons.check_circle_outline_rounded, label: product.inStock ? 'متوفر' : 'غير متوفر', value: 'الحالة', color: product.inStock ? AppColors.success : AppColors.error),
            const _Divider(),
            _InfoPill(icon: Icons.percent_rounded, label: '${product.discount ?? 0}%', value: 'الخصم', color: AppColors.terracotta),
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
            _MetaRow(icon: Icons.verified_outlined, title: 'الماركة', value: product.kind == ProductKind.medicine ? 'VetCare' : 'مزرعتي'),
            const Divider(height: 16),
            _MetaRow(icon: Icons.category_outlined, title: 'القسم', value: product.category.isEmpty ? 'منتجات زراعية' : product.category),
            const Divider(height: 16),
            _MetaRow(icon: Icons.local_shipping_outlined, title: 'التوصيل', value: 'متاح خلال 1-3 أيام'),
          ],
        ),
      );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: AppColors.forest, size: 19), const SizedBox(width: 7), Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 11)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))]);
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, required this.value, this.color = AppColors.forest});
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Icon(icon, size: 20, color: color), const SizedBox(height: 4), Text(label, maxLines: 1, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)), Text(value, style: const TextStyle(color: AppColors.muted, fontSize: 8.5))]));
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: AppColors.border);
}

class _MedicineWarningCard extends StatelessWidget {
  const _MedicineWarningCard();
  @override
  Widget build(BuildContext context) => const AppSurfaceCard(
        color: AppColors.terracottaSoft,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.health_and_safety_outlined, color: AppColors.terracotta), SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تنبيه للاستخدام البيطري', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('يُستخدم وفق الجرعة الموصى بها وتحت إشراف الطبيب البيطري.', style: TextStyle(fontSize: 11))]))]),
      );
}

class _FeedAttributesCard extends StatelessWidget {
  const _FeedAttributesCard();
  @override
  Widget build(BuildContext context) => const AppSurfaceCard(
        color: AppColors.forestSoft,
        child: Row(children: [Expanded(child: _SmallMetric('البروتين', '18%')), Expanded(child: _SmallMetric('الوزن', '50 كجم')), Expanded(child: _SmallMetric('النوع', 'مواشي'))]),
      );
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9))]);
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => onChanged((value + 1).clamp(1, 99)), icon: const Icon(Icons.add_rounded), visualDensity: VisualDensity.compact), SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900))), IconButton(onPressed: () => onChanged((value - 1).clamp(1, 99)), icon: const Icon(Icons.remove_rounded), visualDensity: VisualDensity.compact)]),
      );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    const names = ['الوصف', 'المواصفات', 'الأسئلة', 'التقييمات'];
    return Row(children: List.generate(names.length, (i) => Expanded(child: InkWell(onTap: () => onChanged(i), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: value == i ? AppColors.forest : AppColors.border, width: value == i ? 3 : 1))), child: Text(names[i], textAlign: TextAlign.center, style: TextStyle(color: value == i ? AppColors.forest : AppColors.muted, fontSize: 11, fontWeight: value == i ? FontWeight.w900 : FontWeight.w500))))));
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.product, required this.tab});
  final Product product;
  final int tab;
  @override
  Widget build(BuildContext context) {
    if (tab == 1) {
      return AppSurfaceCard(child: Column(children: const [_MetaRow(icon: Icons.straighten_rounded, title: 'الوزن/الحجم', value: 'حسب العبوة'), Divider(height: 16), _MetaRow(icon: Icons.public_rounded, title: 'بلد المنشأ', value: 'المملكة العربية السعودية'), Divider(height: 16), _MetaRow(icon: Icons.inventory_outlined, title: 'التخزين', value: 'مكان جاف وبارد')]));
    }
    if (tab == 2) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const AppSurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('هل المنتج مناسب للاستخدام اليومي؟', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('نعم، مع اتباع تعليمات الاستخدام المرفقة.', style: TextStyle(color: AppColors.muted))])), const SizedBox(height: 8), OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, '/ask-question'), icon: const Icon(Icons.chat_bubble_outline_rounded), label: const Text('اطرح سؤالًا'))]);
    }
    if (tab == 3) {
      return AppSurfaceCard(child: Row(children: [const Column(children: [Text('4.8', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.forestDark)), Text('★★★★★', style: TextStyle(color: AppColors.warning))]), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: List.generate(5, (i) => Padding(padding: const EdgeInsets.only(bottom: 3), child: Row(children: [Text('${5-i}', style: const TextStyle(fontSize: 9)), const SizedBox(width: 4), Expanded(child: LinearProgressIndicator(value: (5-i)/5, minHeight: 5, borderRadius: BorderRadius.circular(5)))])) ))]));
    }
    return Text(product.description.isEmpty ? 'منتج مختار بعناية من متجر مزرعتي، بجودة موثوقة ومواصفات مناسبة للاستخدام الزراعي والبيطري.' : product.description, style: const TextStyle(height: 1.8, fontSize: 12.5));
  }
}

class ReferenceReviewsQuestionsScreen extends StatefulWidget {
  const ReferenceReviewsQuestionsScreen({super.key, required this.product});
  final Product product;
  @override
  State<ReferenceReviewsQuestionsScreen> createState() => _ReferenceReviewsQuestionsScreenState();
}

class _ReferenceReviewsQuestionsScreenState extends State<ReferenceReviewsQuestionsScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'التقييمات والأسئلة'),
        body: AppPage(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _MiniProductHeader(product: widget.product),
            const SizedBox(height: 13),
            SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('التقييمات')), ButtonSegment(value: 1, label: Text('الأسئلة'))], selected: {tab}, showSelectedIcon: false, onSelectionChanged: (value) => setState(() => tab = value.first)),
            const SizedBox(height: 14),
            if (tab == 0) ...[
              const _RatingSummary(),
              const SizedBox(height: 10),
              ..._reviews.map((review) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _ReviewCard(review))),
            ] else ...[
              ..._questions.map((q) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _QuestionCard(q.$1, q.$2))),
              const SizedBox(height: 8),
              FilledButton.icon(onPressed: () => Navigator.pushNamed(context, '/ask-question'), icon: const Icon(Icons.add_comment_outlined), label: const Text('اطرح سؤالًا')),
            ],
          ]),
        ),
      );

  static const _reviews = [
    'منتج ممتاز وجودته عالية ووصل بتغليف جيد.',
    'مطابق للوصف والسعر مناسب مقارنة بالجودة.',
    'تجربة شراء موفقة وسأطلبه مرة أخرى.',
  ];
  static const _questions = [
    ('هل يتوفر شحن إلى جميع المناطق؟', 'نعم، تتوفر خيارات الشحن بحسب عنوانك.'),
    ('ما مدة الصلاحية؟', 'تظهر مدة الصلاحية وتاريخ الإنتاج على العبوة.'),
    ('هل المنتج أصلي؟', 'جميع المنتجات في مزرعتي من موردين موثقين.'),
  ];
}

class ReferenceAskQuestionScreen extends StatelessWidget {
  const ReferenceAskQuestionScreen({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'اسأل عن المنتج'),
        body: AppPage(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _MiniProductHeader(product: product),
            const SizedBox(height: 18),
            const Text('ما سؤالك؟', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            const TextField(maxLines: 6, maxLength: 500, decoration: InputDecoration(hintText: 'اكتب سؤالك بوضوح ليتمكن البائع أو المشترون من مساعدتك...')),
            const SizedBox(height: 10),
            const Text('أسئلة شائعة', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: ['هل المنتج متوفر؟', 'كم مدة التوصيل؟', 'هل يوجد ضمان؟', 'ما بلد المنشأ؟'].map((e) => ActionChip(label: Text(e), onPressed: () {})).toList()),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال سؤالك'))), icon: const Icon(Icons.send_rounded), label: const Text('إرسال السؤال')),
            const SizedBox(height: 10),
            const Text('سيظهر السؤال بعد المراجعة، وسيصلك إشعار عند الرد عليه.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 10.5)),
          ]),
        ),
      );
}

class _MiniProductHeader extends StatelessWidget {
  const _MiniProductHeader({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 82, height: 68, child: AppDataImage(product.image, fit: BoxFit.cover))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(formatPrice(product.price), style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w900))]))]));
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary();
  @override
  Widget build(BuildContext context) => AppSurfaceCard(child: Row(children: [const SizedBox(width: 88, child: Column(children: [Text('4.8', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.forestDark)), Text('★★★★★', style: TextStyle(color: AppColors.warning, fontSize: 13)), Text('126 تقييم', style: TextStyle(color: AppColors.muted, fontSize: 9))])), const SizedBox(width: 12), Expanded(child: Column(children: List.generate(5, (index) { final star = 5-index; return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Text('$star', style: const TextStyle(fontSize: 9)), const SizedBox(width: 5), Expanded(child: LinearProgressIndicator(value: star == 5 ? .8 : star == 4 ? .5 : .16, minHeight: 6, borderRadius: BorderRadius.circular(6))), const SizedBox(width: 5), Text('${star*8}', style: const TextStyle(fontSize: 9, color: AppColors.muted))])); })))]));
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [CircleAvatar(radius: 18, backgroundColor: AppColors.forestSoft, child: Icon(Icons.person_outline_rounded, color: AppColors.forest)), SizedBox(width: 8), Expanded(child: Text('عميل موثّق', style: TextStyle(fontWeight: FontWeight.w900))), Text('★★★★★', style: TextStyle(color: AppColors.warning, fontSize: 11))]), const SizedBox(height: 8), Text(text), const SizedBox(height: 7), const Text('شراء موثّق • منذ أسبوعين', style: TextStyle(color: AppColors.muted, fontSize: 9.5))]));
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard(this.question, this.answer);
  final String question;
  final String answer;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const CircleAvatar(radius: 13, backgroundColor: AppColors.terracottaSoft, child: Text('س', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900))), const SizedBox(width: 8), Expanded(child: Text(question, style: const TextStyle(fontWeight: FontWeight.w900)))]), const Divider(height: 18), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const CircleAvatar(radius: 13, backgroundColor: AppColors.forestSoft, child: Text('ج', style: TextStyle(color: AppColors.forest, fontWeight: FontWeight.w900))), const SizedBox(width: 8), Expanded(child: Text(answer, style: const TextStyle(color: AppColors.muted)))]) ]));
}

String _kind(ProductKind kind) => switch (kind) {
      ProductKind.crop => 'زراعي',
      ProductKind.animal => 'حيواني',
      ProductKind.supply => 'مستلزمات',
      ProductKind.medicine => 'دواء بيطري',
      ProductKind.feed => 'أعلاف',
    };
