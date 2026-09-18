import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'unified_product_details_screen.dart';

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

class MatchedProductDetailsScreen extends StatelessWidget {
  const MatchedProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) =>
      UnifiedProductDetailsScreen(product: product);
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
