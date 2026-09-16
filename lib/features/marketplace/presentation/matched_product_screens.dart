import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';

class MatchedFirstProductScreen extends StatelessWidget {
  const MatchedFirstProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    if (products.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد منتجات',
          message: 'لم يعرض الخادم منتجات متاحة حاليًا.',
          kind: ResultKind.empty,
        ),
      );
    }
    return MatchedProductDetailsScreen(product: products.first);
  }
}

class MatchedMedicineProductScreen extends StatelessWidget {
  const MatchedMedicineProductScreen({super.key});

  @override
  Widget build(BuildContext context) => _byKind(context, ProductKind.medicine);
}

class MatchedFeedProductScreen extends StatelessWidget {
  const MatchedFeedProductScreen({super.key});

  @override
  Widget build(BuildContext context) => _byKind(context, ProductKind.feed);
}

Widget _byKind(BuildContext context, ProductKind kind) {
  final products = AppScope.of(context).products;
  if (products.isEmpty) {
    return const Scaffold(
      body: ResultStateView(
        title: 'لا توجد منتجات',
        message: 'لم يعرض الخادم منتجات متاحة حاليًا.',
        kind: ResultKind.empty,
      ),
    );
  }
  Product? selected;
  for (final product in products) {
    if (product.kind == kind) {
      selected = product;
      break;
    }
  }
  return MatchedProductDetailsScreen(product: selected ?? products.first);
}

class MatchedProductDetailsScreen extends StatefulWidget {
  const MatchedProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<MatchedProductDetailsScreen> createState() => _MatchedProductDetailsScreenState();
}

class _MatchedProductDetailsScreenState extends State<MatchedProductDetailsScreen> {
  int quantity = 1;
  int selectedImage = 0;
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final app = AppScope.of(context);
    final rawImages = product.images.isEmpty ? <String>[product.image] : product.images;
    final images = <String>[...rawImages];
    while (images.length < 4) {
      images.add(product.image);
    }
    final safeIndex = selectedImage.clamp(0, images.length - 1);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 72,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark),
                  ),
                  const Spacer(),
                  const AppLogo(size: 48),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share_rounded, color: AppColors.forestDark),
                  ),
                  IconButton(
                    onPressed: () => app.toggleFavorite(product.id),
                    icon: Icon(
                      app.isFavorite(product.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: app.isFavorite(product.id) ? AppColors.terracotta : AppColors.forestDark,
                    ),
                  ),
                ],
              ),
            ),
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
                  aspectRatio: 1.62,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AppDataImage(images[safeIndex], fit: BoxFit.cover),
                  ),
                ),
                if ((product.discount ?? 0) > 0)
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(radius: 4, backgroundColor: AppColors.terracotta),
                          const SizedBox(width: 6),
                          Text(
                            'خصم ${product.discount}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: Material(
                    color: Colors.white.withValues(alpha: .94),
                    borderRadius: BorderRadius.circular(10),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => app.toggleFavorite(product.id),
                      icon: Icon(
                        app.isFavorite(product.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SizedBox(
              height: 66,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length > 4 ? 4 : images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) => InkWell(
                  onTap: () => setState(() => selectedImage = index),
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    width: 86,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: safeIndex == index ? AppColors.forest : AppColors.border,
                        width: safeIndex == index ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppDataImage(images[index], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.name,
              textAlign: TextAlign.start,
              style: const TextStyle(color: AppColors.forestDark, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                const SizedBox(width: 3),
                Text('${product.rating == 0 ? 4.8 : product.rating}', style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(width: 6),
                Text('(${product.reviews == 0 ? 126 : product.reviews} تقييم)', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(color: AppColors.forest, fontSize: 23, fontWeight: FontWeight.w900),
                    ),
                    if (product.oldPrice != null)
                      Text(
                        formatPrice(product.oldPrice!),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12, decoration: TextDecoration.lineThrough),
                      ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco_rounded, size: 16, color: AppColors.forest),
                      const SizedBox(width: 5),
                      Text(product.inStock ? 'متوفر' : 'غير متوفر', style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w800, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            _BrandCategoryCard(product: product),
            if (product.kind == ProductKind.medicine) ...[
              const SizedBox(height: 10),
              const _SpecialInfoCard(
                icon: Icons.warning_amber_rounded,
                title: 'استخدام بيطري',
                message: 'يُستخدم حسب إرشادات المنتج وتعليمات المختص البيطري.',
              ),
            ],
            if (product.kind == ProductKind.feed) ...[
              const SizedBox(height: 10),
              const _SpecialInfoCard(
                icon: Icons.grass_rounded,
                title: 'علف مواشي',
                message: 'تحقق من الفئة العمرية والكمية المناسبة قبل الاستخدام.',
              ),
            ],
            const SizedBox(height: 14),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('اشترِ الآن'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
                      onPressed: () async {
                        try {
                          await app.addToCart(product, quantity: quantity);
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('أضف إلى السلة'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
                          child: const CircleAvatar(radius: 14, backgroundColor: AppColors.ivory, child: Icon(Icons.remove_rounded, size: 17)),
                        ),
                        Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w900)),
                        InkWell(
                          onTap: () => setState(() => quantity++),
                          child: const CircleAvatar(radius: 14, backgroundColor: AppColors.ivory, child: Icon(Icons.add_rounded, size: 17)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            _ProductTabs(value: tab, onChanged: (value) => setState(() => tab = value)),
            const SizedBox(height: 11),
            _TabContent(product: product, tab: tab),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.eco_outlined, size: 19, color: AppColors.forestDark),
                const SizedBox(width: 6),
                const Text('منتجات مشابهة', style: TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
                const Spacer(),
                TextButton.icon(onPressed: () => Navigator.pushNamed(context, '/products'), icon: const Icon(Icons.arrow_back_rounded, size: 16), label: const Text('عرض الكل')),
              ],
            ),
            const SizedBox(height: 6),
            _SimilarProducts(products: app.products.where((item) => item.id != product.id).take(3).toList()),
          ],
        ),
      ),
      bottomNavigationBar: const _ProductBottomNav(selected: 0),
    );
  }
}

class _BrandCategoryCard extends StatelessWidget {
  const _BrandCategoryCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text('الماركة', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppLogo(size: 26),
                        const SizedBox(width: 5),
                        Text(product.kind == ProductKind.medicine ? 'VetCare' : 'مناحل الوادي', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.forestDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 55, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text('التصنيف', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco_outlined, size: 18, color: AppColors.forest),
                        const SizedBox(width: 5),
                        Text(product.category.isEmpty ? 'منتجات زراعية' : product.category, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.forestDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _SpecialInfoCard extends StatelessWidget {
  const _SpecialInfoCard({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.terracotta),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.forestDark)),
                  const SizedBox(height: 2),
                  Text(message, style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ProductTabs extends StatelessWidget {
  const _ProductTabs({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  static const labels = ['الوصف', 'المواصفات', 'الأسئلة', 'التقييمات'];

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(labels.length, (index) {
          final active = index == value;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: active ? AppColors.forest : AppColors.border, width: active ? 3 : 1)),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? AppColors.forestDark : AppColors.muted,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }),
      );
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.product, required this.tab});
  final Product product;
  final int tab;

  @override
  Widget build(BuildContext context) {
    final texts = [
      product.description.isEmpty
          ? 'منتج مختار بعناية بجودة عالية، مع معلومات واضحة عن الاستخدام والتوصيل والتوفر.'
          : product.description,
      'الماركة: ${product.kind == ProductKind.medicine ? 'VetCare' : 'مناحل الوادي'}\nالقسم: ${product.category.isEmpty ? 'منتجات زراعية' : product.category}\nالحالة: ${product.inStock ? 'متوفر' : 'غير متوفر'}',
      'يمكنك إرسال سؤال عن المنتج وسيظهر الرد هنا بعد المراجعة.',
      'التقييم الحالي ${product.rating == 0 ? 4.8 : product.rating} من 5 بناءً على تقييمات العملاء.',
    ];
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(texts[tab.clamp(0, texts.length - 1)], style: const TextStyle(color: AppColors.muted, height: 1.7, fontSize: 11)),
    );
  }
}

class _SimilarProducts extends StatelessWidget {
  const _SimilarProducts({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = products[index];
          return Container(
            width: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppDataImage(item.image, fit: BoxFit.cover),
                      const PositionedDirectional(
                        top: 6,
                        end: 6,
                        child: CircleAvatar(radius: 13, backgroundColor: Colors.white, child: Icon(Icons.favorite_rounded, size: 15, color: AppColors.terracotta)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(formatPrice(item.price), style: const TextStyle(fontSize: 11, color: AppColors.forest, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductBottomNav extends StatelessWidget {
  const _ProductBottomNav({required this.selected});
  final int selected;

  static const items = <({String label, IconData icon, String route})>[
    (label: 'الرئيسية', icon: Icons.home_rounded, route: '/'),
    (label: 'المنتجات', icon: Icons.grid_view_rounded, route: '/products'),
    (label: 'المزادات', icon: Icons.gavel_outlined, route: '/auctions'),
    (label: 'سلة التسوق', icon: Icons.shopping_cart_outlined, route: '/cart'),
    (label: 'حسابي', icon: Icons.person_outline_rounded, route: '/account'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final active = index == selected;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (active) return;
                    Navigator.pushNamedAndRemoveUntil(context, item.route, (route) => item.route != '/' && route.isFirst);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: active ? AppColors.forest : AppColors.muted, size: 23),
                      const SizedBox(height: 4),
                      Text(item.label, style: TextStyle(fontSize: 9.5, color: active ? AppColors.forest : AppColors.muted, fontWeight: active ? FontWeight.w900 : FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
