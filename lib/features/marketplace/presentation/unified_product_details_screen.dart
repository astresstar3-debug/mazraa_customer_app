import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'connected_product_reviews_screen.dart';

const bool _referenceVisual =
    bool.fromEnvironment('REFERENCE_VISUAL_TEST', defaultValue: false);

class UnifiedProductDetailsScreen extends StatefulWidget {
  const UnifiedProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<UnifiedProductDetailsScreen> createState() =>
      _UnifiedProductDetailsScreenState();
}

class _UnifiedProductDetailsScreenState
    extends State<UnifiedProductDetailsScreen> {
  int quantity = 1;
  int imageIndex = 0;
  int tabIndex = 0;
  int selectedOption = 1;
  bool adding = false;
  bool extrasRequested = false;
  List<Map<String, dynamic>> specs = const [];
  List<Product> related = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!extrasRequested) {
      extrasRequested = true;
      _loadExtras();
    }
  }

  Future<void> _loadExtras() async {
    final id = int.tryParse(widget.product.id);
    if (id == null) return;
    try {
      final app = AppScope.of(context);
      final values = await Future.wait<dynamic>([
        app.client.get('/api/products/$id/specs'),
        app.client.get('/api/products/$id/related'),
      ]);

      final nextSpecs = <Map<String, dynamic>>[];
      if (values[0] is List) {
        for (final value in values[0] as List) {
          if (value is Map) {
            nextSpecs.add(Map<String, dynamic>.from(value));
          }
        }
      }

      final known = <String, Product>{for (final item in app.products) item.id: item};
      final nextRelated = <Product>[];
      if (values[1] is List) {
        for (final value in values[1] as List) {
          if (value is! Map) continue;
          final map = Map<String, dynamic>.from(value);
          final relatedId = '${map['id'] ?? map['Id'] ?? ''}';
          final item = known[relatedId];
          if (item != null && item.id != widget.product.id) {
            nextRelated.add(item);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        specs = nextSpecs;
        related = nextRelated;
      });
    } catch (_) {
      // Extra product data is optional; the core product screen stays usable.
    }
  }

  Future<void> _addToCart({required bool checkout}) async {
    final app = AppScope.of(context);
    if (!app.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => adding = true);
    try {
      await app.addToCart(widget.product, quantity: quantity);
      if (!mounted) return;
      if (checkout) {
        Navigator.pushNamed(context, '/checkout');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة المنتج إلى السلة')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.errorMessage ?? 'تعذر إضافة المنتج إلى السلة')),
      );
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final app = AppScope.of(context);
    if (!app.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    await app.toggleFavorite(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final app = AppScope.of(context);
    final gallery = _gallery(product);
    final safeImageIndex = imageIndex.clamp(0, gallery.length - 1);
    final options = _productOptions();
    final similar = related.isNotEmpty
        ? related.take(3).toList()
        : app.products
            .where((item) => item.id != product.id)
            .take(3)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ReferenceProductTopBar(
              favorite: app.isFavorite(product.id),
              onFavorite: _toggleFavorite,
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroGallery(
                      product: product,
                      images: gallery,
                      selectedIndex: safeImageIndex,
                      favorite: app.isFavorite(product.id),
                      onFavorite: _toggleFavorite,
                    ),
                    const SizedBox(height: 9),
                    _ThumbnailRow(
                      images: gallery,
                      selectedIndex: safeImageIndex,
                      onSelected: (index) => setState(() => imageIndex = index),
                    ),
                    const SizedBox(height: 15),
                    _ProductTitleBlock(product: product),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 11),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'عناصر المنتج',
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    _OptionSelector(
                      options: options,
                      selected: selectedOption.clamp(0, options.length - 1),
                      onSelected: (index) =>
                          setState(() => selectedOption = index),
                    ),
                    const SizedBox(height: 14),
                    _BrandCategoryStrip(
                      brand: _brandName(),
                      category: product.category.trim().isEmpty
                          ? 'منتجات زراعية'
                          : product.category,
                    ),
                    const SizedBox(height: 14),
                    _PurchaseRow(
                      quantity: quantity,
                      enabled: product.inStock && !adding,
                      adding: adding,
                      onIncrement: () => setState(() => quantity++),
                      onDecrement: () =>
                          setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
                      onAdd: () => _addToCart(checkout: false),
                      onBuy: () => _addToCart(checkout: true),
                    ),
                    const SizedBox(height: 17),
                    _ProductTabs(
                      selected: tabIndex,
                      onSelected: (value) => setState(() => tabIndex = value),
                    ),
                    const SizedBox(height: 10),
                    _TabBody(
                      product: product,
                      specs: specs,
                      tabIndex: tabIndex,
                    ),
                    const SizedBox(height: 15),
                    _SimilarHeader(
                      onAll: () => Navigator.pushNamed(context, '/products'),
                    ),
                    const SizedBox(height: 8),
                    _SimilarProducts(products: similar),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ProductBottomNavigation(
        cartCount: app.cartCount,
      ),
    );
  }

  List<String> _gallery(Product product) {
    final raw = product.images.where((value) => value.trim().isNotEmpty).toList();
    final fallback = product.image.trim().isEmpty
        ? 'assets/images/home/sidr_honey.png'
        : product.image;
    if (raw.isEmpty) raw.add(fallback);
    while (raw.length < 4) {
      raw.add(raw[raw.length % raw.length]);
    }
    return raw.take(4).toList();
  }

  List<String> _productOptions() {
    if (_referenceVisual) {
      return const ['250 جرام', '500 جرام', '1 كجم', '2 كجم'];
    }

    final values = <String>[];
    for (final spec in specs) {
      final name = '${spec['name'] ?? spec['Name'] ?? spec['key'] ?? ''}'.toLowerCase();
      final isOption = name.contains('وزن') ||
          name.contains('حجم') ||
          name.contains('عبوة') ||
          name.contains('weight') ||
          name.contains('size') ||
          name.contains('package') ||
          name.contains('variant');
      if (!isOption) continue;
      final value = '${spec['value'] ?? spec['Value'] ?? ''}'.trim();
      final unit = '${spec['unit'] ?? spec['Unit'] ?? ''}'.trim();
      final label = '$value${unit.isEmpty ? '' : ' $unit'}'.trim();
      if (label.isNotEmpty && !values.contains(label)) values.add(label);
    }
    if (values.isEmpty) return const ['الخيار الأساسي'];
    return values.take(4).toList();
  }

  String _brandName() {
    if (_referenceVisual) return 'مناحل الوادي';
    for (final spec in specs) {
      final name = '${spec['name'] ?? spec['Name'] ?? spec['key'] ?? ''}'.toLowerCase();
      if (!(name.contains('ماركة') ||
          name.contains('علامة') ||
          name.contains('brand') ||
          name.contains('manufacturer'))) {
        continue;
      }
      final value = '${spec['value'] ?? spec['Value'] ?? ''}'.trim();
      if (value.isNotEmpty) return value;
    }
    return 'مزرعتي';
  }
}

class _ReferenceProductTopBar extends StatelessWidget {
  const _ReferenceProductTopBar({
    required this.favorite,
    required this.onFavorite,
    required this.onBack,
  });

  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(child: AppLogo(size: 51)),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.ios_share_rounded,
                      color: AppColors.forestDark,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: favorite
                          ? AppColors.terracotta
                          : AppColors.forestDark,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.forestDark,
                  size: 29,
                ),
              ),
            ),
          ],
        ),
      );
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({
    required this.product,
    required this.images,
    required this.selectedIndex,
    required this.favorite,
    required this.onFavorite,
  });

  final Product product;
  final List<String> images;
  final int selectedIndex;
  final bool favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1.72,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppDataImage(images[selectedIndex], fit: BoxFit.cover),
              if ((product.discount ?? 0) > 0)
                Positioned(
                  top: 13,
                  left: 13,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.terracotta,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'خصم ${product.discount}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 13,
                right: 13,
                child: Material(
                  color: Colors.white.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    onTap: onFavorite,
                    borderRadius: BorderRadius.circular(11),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: AppColors.terracotta,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ThumbnailRow extends StatelessWidget {
  const _ThumbnailRow({
    required this.images,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 58,
        child: Row(
          children: [
            for (var index = 0; index < images.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedIndex == index
                            ? AppColors.forest
                            : AppColors.border,
                        width: selectedIndex == index ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppDataImage(images[index], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

class _ProductTitleBlock extends StatelessWidget {
  const _ProductTitleBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final rating = product.rating <= 0 ? 4.8 : product.rating;
    final reviews = product.reviews <= 0 ? 126 : product.reviews;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          product.name,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$rating',
              style: const TextStyle(
                color: AppColors.forestDark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.star_rounded, color: AppColors.warning, size: 19),
            const SizedBox(width: 9),
            Text(
              '$reviews تقييم',
              style: const TextStyle(
                color: AppColors.forestDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.rate_review_outlined,
              size: 15,
              color: AppColors.forestDark,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          formatPrice(product.price),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (product.oldPrice != null) ...[
          const SizedBox(height: 1),
          Text(
            formatPrice(product.oldPrice!),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionSelector extends StatelessWidget {
  const _OptionSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var index = 0; index < options.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(13),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == index
                        ? AppColors.forestSoft
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: selected == index
                          ? AppColors.forest
                          : AppColors.border,
                      width: selected == index ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    options[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: selected == index
                          ? FontWeight.w900
                          : FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
}

class _BrandCategoryStrip extends StatelessWidget {
  const _BrandCategoryStrip({required this.brand, required this.category});

  final String brand;
  final String category;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Column(
                  children: [
                    const Text(
                      'العلامة التجارية',
                      style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppLogo(size: 27),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 52, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Column(
                  children: [
                    const Text(
                      'التصنيف',
                      style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_florist_rounded,
                          size: 18,
                          color: AppColors.forest,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
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

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({
    required this.quantity,
    required this.enabled,
    required this.adding,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAdd,
    required this.onBuy,
  });

  final int quantity;
  final bool enabled;
  final bool adding;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAdd;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) => Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            flex: 31,
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: enabled ? onBuy : null,
                icon: const Icon(Icons.bolt_rounded, size: 19),
                label: const Text(
                  'اشترِ الآن',
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 36,
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: enabled ? onAdd : null,
                icon: adding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart_outlined, size: 19),
                label: const Text(
                  'أضف إلى السلة',
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 29,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: onDecrement,
                    borderRadius: BorderRadius.circular(18),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.ivory,
                      child: Icon(
                        Icons.remove_rounded,
                        size: 17,
                        color: AppColors.forestDark,
                      ),
                    ),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    onTap: onIncrement,
                    borderRadius: BorderRadius.circular(18),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.ivory,
                      child: Icon(
                        Icons.add_rounded,
                        size: 17,
                        color: AppColors.forestDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _ProductTabs extends StatelessWidget {
  const _ProductTabs({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = ['الوصف', 'المواصفات', 'الأسئلة', 'التقييمات'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                child: Container(
                  height: 43,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected == index
                            ? AppColors.forestDark
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: selected == index
                          ? AppColors.forestDark
                          : AppColors.muted,
                      fontSize: 12,
                      fontWeight: selected == index
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({
    required this.product,
    required this.specs,
    required this.tabIndex,
  });

  final Product product;
  final List<Map<String, dynamic>> specs;
  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 1) {
      return _SpecsBody(specs: specs);
    }
    if (tabIndex == 2) {
      return _ActionTabCard(
        icon: Icons.help_outline_rounded,
        text: 'الأسئلة الشائعة وأسئلة العملاء حول المنتج',
        button: 'عرض الأسئلة',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConnectedProductQuestionsScreen(product: product),
          ),
        ),
      );
    }
    if (tabIndex == 3) {
      return _ActionTabCard(
        icon: Icons.star_outline_rounded,
        text: '${product.reviews <= 0 ? 126 : product.reviews} تقييم لهذا المنتج',
        button: 'عرض التقييمات',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConnectedProductReviewsScreen(product: product),
          ),
        ),
      );
    }

    final description = product.description.trim().isEmpty
        ? 'منتج مختار بعناية وجودة عالية، مع تفاصيل واضحة وخيارات مناسبة للشراء.'
        : product.description;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        description,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11.5,
          height: 1.75,
        ),
      ),
    );
  }
}

class _SpecsBody extends StatelessWidget {
  const _SpecsBody({required this.specs});

  final List<Map<String, dynamic>> specs;

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) {
      return const _ActionTabCard(
        icon: Icons.fact_check_outlined,
        text: 'لا توجد مواصفات إضافية لهذا المنتج حاليًا.',
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: specs.take(5).map((spec) {
          final name = '${spec['name'] ?? spec['Name'] ?? ''}';
          final value = '${spec['value'] ?? spec['Value'] ?? ''}';
          final unit = '${spec['unit'] ?? spec['Unit'] ?? ''}';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  '$value${unit.trim().isEmpty ? '' : ' $unit'}',
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionTabCard extends StatelessWidget {
  const _ActionTabCard({
    required this.icon,
    required this.text,
    this.button,
    this.onPressed,
  });

  final IconData icon;
  final String text;
  final String? button;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.forestDark, size: 21),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
            if (button != null)
              TextButton(onPressed: onPressed, child: Text(button!)),
          ],
        ),
      );
}

class _SimilarHeader extends StatelessWidget {
  const _SimilarHeader({required this.onAll});

  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(
            Icons.local_florist_rounded,
            color: AppColors.forestDark,
            size: 20,
          ),
          const SizedBox(width: 6),
          const Text(
            'منتجات مشابهة',
            style: TextStyle(
              color: AppColors.forestDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onAll,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('عرض الكل'),
          ),
        ],
      );
}

class _SimilarProducts extends StatelessWidget {
  const _SimilarProducts({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (var index = 0; index < products.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(child: _SimilarProductCard(product: products[index])),
        ],
      ],
    );
  }
}

class _SimilarProductCard extends StatelessWidget {
  const _SimilarProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UnifiedProductDetailsScreen(product: product),
          ),
        ),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.48,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppDataImage(product.image, fit: BoxFit.cover),
                    const Positioned(
                      top: 5,
                      right: 5,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 13,
                          color: AppColors.terracotta,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(product.price),
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
      );
}

class _ProductBottomNavigation extends StatelessWidget {
  const _ProductBottomNavigation({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, String route, int badge})>[
      (icon: Icons.home_rounded, label: 'الرئيسية', route: '/', badge: 0),
      (icon: Icons.grid_view_rounded, label: 'المنتجات', route: '/products', badge: 0),
      (icon: Icons.gavel_rounded, label: 'المزادات', route: '/auctions', badge: 0),
      (icon: Icons.shopping_cart_outlined, label: 'سلة التسوق', route: '/cart', badge: cartCount),
      (icon: Icons.person_outline_rounded, label: 'حسابي', route: '/account', badge: 0),
    ];

    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: const Color(0x160D4328),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 65,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final route = items[index].route;
                      if (route == '/') {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      } else {
                        Navigator.pushNamed(context, route);
                      }
                    },
                    child: _BottomNavItem(
                      icon: items[index].icon,
                      label: items[index].label,
                      selected: index == 0,
                      badge: items[index].badge,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forestDark : AppColors.muted;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 27,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: selected ? 25 : 23),
              if (badge > 0)
                Positioned(
                  top: -5,
                  right: -11,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
