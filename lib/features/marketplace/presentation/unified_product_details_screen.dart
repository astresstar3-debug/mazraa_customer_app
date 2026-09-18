import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'connected_product_reviews_screen.dart';

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
  int selectedOption = 0;
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

      final known = <String, Product>{
        for (final item in app.products) item.id: item,
      };
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
        selectedOption = 0;
      });
    } catch (_) {
      // Specs and related products are optional. The unified details screen
      // remains usable with the core product payload returned by the server.
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
        SnackBar(
          content: Text(app.errorMessage ?? 'تعذر إضافة المنتج إلى السلة'),
        ),
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
    if (mounted) setState(() {});
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('مشاركة ${widget.product.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final product = widget.product;
    final gallery = _gallery(product);
    final options = _productOptions();
    final safeImageIndex = imageIndex.clamp(0, gallery.length - 1);
    final safeOptionIndex = selectedOption.clamp(0, options.length - 1);
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
            _ProductHeader(
              favorite: app.isFavorite(product.id),
              onBack: () => Navigator.maybePop(context),
              onFavorite: _toggleFavorite,
              onShare: _shareProduct,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(17, 3, 17, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProductHero(
                      product: product,
                      image: gallery[safeImageIndex],
                      favorite: app.isFavorite(product.id),
                      onFavorite: _toggleFavorite,
                    ),
                    const SizedBox(height: 11),
                    _Thumbnails(
                      images: gallery,
                      selected: safeImageIndex,
                      onSelected: (index) => setState(() => imageIndex = index),
                    ),
                    const SizedBox(height: 18),
                    _TitlePriceBlock(product: product),
                    const SizedBox(height: 18),
                    const _SectionLabel('عناصر المنتج'),
                    const SizedBox(height: 9),
                    _OptionsRow(
                      options: options,
                      selected: safeOptionIndex,
                      onSelected: (index) =>
                          setState(() => selectedOption = index),
                    ),
                    const SizedBox(height: 16),
                    _BrandCategoryRow(
                      brand: _brandName(),
                      category: product.category.trim().isEmpty
                          ? 'منتجات'
                          : product.category,
                    ),
                    const SizedBox(height: 16),
                    _PurchaseRow(
                      quantity: quantity,
                      enabled: product.inStock && !adding,
                      adding: adding,
                      onIncrement: () => setState(() => quantity++),
                      onDecrement: () => setState(
                        () => quantity = quantity > 1 ? quantity - 1 : 1,
                      ),
                      onAdd: () => _addToCart(checkout: false),
                      onBuy: () => _addToCart(checkout: true),
                    ),
                    const SizedBox(height: 17),
                    _Tabs(
                      selected: tabIndex,
                      onSelected: (index) => setState(() => tabIndex = index),
                    ),
                    const SizedBox(height: 11),
                    _TabBody(
                      product: product,
                      specs: specs,
                      tabIndex: tabIndex,
                    ),
                    const SizedBox(height: 16),
                    _SimilarTitle(
                      onAll: () => Navigator.pushNamed(context, '/products'),
                    ),
                    const SizedBox(height: 9),
                    _SimilarProducts(products: similar),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavigation(cartCount: app.cartCount),
    );
  }

  List<String> _gallery(Product product) {
    final values = product.images
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: true);
    if (values.isEmpty && product.image.trim().isNotEmpty) {
      values.add(product.image);
    }
    if (values.isEmpty) {
      values.add('assets/images/home/sidr_honey.png');
    }
    final first = values.first;
    while (values.length < 4) {
      values.add(first);
    }
    return values.take(4).toList(growable: false);
  }

  List<String> _productOptions() {
    final values = <String>[];
    for (final spec in specs) {
      final name = '${spec['name'] ?? spec['Name'] ?? spec['key'] ?? ''}'
          .trim()
          .toLowerCase();
      final isOption = name.contains('وزن') ||
          name.contains('حجم') ||
          name.contains('عبوة') ||
          name.contains('مقاس') ||
          name.contains('نوع') ||
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
    return values.take(4).toList(growable: false);
  }

  String _brandName() {
    for (final spec in specs) {
      final name = '${spec['name'] ?? spec['Name'] ?? spec['key'] ?? ''}'
          .trim()
          .toLowerCase();
      if (!(name.contains('ماركة') ||
          name.contains('علامة') ||
          name.contains('brand') ||
          name.contains('manufacturer') ||
          name.contains('مصنع'))) {
        continue;
      }
      final value = '${spec['value'] ?? spec['Value'] ?? ''}'.trim();
      if (value.isNotEmpty) return value;
    }
    return 'مزرعتي';
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    required this.favorite,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
  });

  final bool favorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(child: AppLogo(size: 52)),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.forestDark,
                  size: 28,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(
                      Icons.ios_share_rounded,
                      color: AppColors.forestDark,
                      size: 25,
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
                      size: 27,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({
    required this.product,
    required this.image,
    required this.favorite,
    required this.onFavorite,
  });

  final Product product;
  final String image;
  final bool favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1.72,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppDataImage(image, fit: BoxFit.cover),
              if ((product.discount ?? 0) > 0)
                Positioned(
                  top: 13,
                  left: 13,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                            fontSize: 12.5,
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
                  color: const Color(0xF5FFFDF8),
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

class _Thumbnails extends StatelessWidget {
  const _Thumbnails({
    required this.images,
    required this.selected,
    required this.onSelected,
  });

  final List<String> images;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 66,
        child: Row(
          children: [
            for (var i = 0; i < images.length; i++) ...[
              if (i > 0) const SizedBox(width: 9),
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(1.3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: i == selected
                            ? AppColors.forest
                            : AppColors.border,
                        width: i == selected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppDataImage(images[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

class _TitlePriceBlock extends StatelessWidget {
  const _TitlePriceBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final rating = product.rating <= 0 ? 0 : product.rating;
    final reviews = product.reviews;
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
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (reviews > 0) ...[
              const Icon(
                Icons.rate_review_outlined,
                size: 15,
                color: AppColors.forestDark,
              ),
              const SizedBox(width: 4),
              Text(
                '$reviews تقييم',
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
            ],
            if (rating > 0) ...[
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 19),
            ],
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
          const SizedBox(height: 2),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: InkWell(
              onTap: () => onSelected(i),
              borderRadius: BorderRadius.circular(13),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected
                      ? const Color(0xFFF4F6EB)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color:
                        i == selected ? AppColors.forest : AppColors.border,
                    width: i == selected ? 1.6 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x090D4328),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    options[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 12,
                      fontWeight:
                          i == selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BrandCategoryRow extends StatelessWidget {
  const _BrandCategoryRow({required this.brand, required this.category});

  final String brand;
  final String category;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                        const AppLogo(size: 26),
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
            Container(width: 1, height: 48, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                          color: AppColors.forest,
                          size: 18,
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
            flex: 30,
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: enabled ? onBuy : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                onPressed: enabled ? onAdd : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: adding
                    ? const SizedBox(
                        width: 17,
                        height: 17,
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
                  _QuantityButton(icon: Icons.remove_rounded, onTap: onDecrement),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  _QuantityButton(icon: Icons.add_rounded, onTap: onIncrement),
                ],
              ),
            ),
          ),
        ],
      );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.ivory,
          child: Icon(icon, size: 17, color: AppColors.forestDark),
        ),
      );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onSelected});

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
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(i),
                child: Container(
                  height: 43,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == selected
                            ? AppColors.forestDark
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: i == selected
                          ? AppColors.forestDark
                          : AppColors.muted,
                      fontSize: 12,
                      fontWeight:
                          i == selected ? FontWeight.w900 : FontWeight.w700,
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
    if (tabIndex == 1) return _SpecsBody(specs: specs);
    if (tabIndex == 2) {
      return _ActionCard(
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
      return _ActionCard(
        icon: Icons.star_outline_rounded,
        text: product.reviews > 0
            ? '${product.reviews} تقييم لهذا المنتج'
            : 'لا توجد تقييمات لهذا المنتج حتى الآن',
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
        ? 'لا يوجد وصف إضافي لهذا المنتج حاليًا.'
        : product.description;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
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
      return const _ActionCard(
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
        children: specs.take(8).map((spec) {
          final name = '${spec['name'] ?? spec['Name'] ?? spec['key'] ?? ''}';
          final value = '${spec['value'] ?? spec['Value'] ?? ''}';
          final unit = '${spec['unit'] ?? spec['Unit'] ?? ''}';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Text(
                    name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 12),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: AppColors.forestDark, size: 21),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
            if (button != null)
              TextButton(onPressed: onPressed, child: Text(button!)),
          ],
        ),
      );
}

class _SimilarTitle extends StatelessWidget {
  const _SimilarTitle({required this.onAll});
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) => Row(
        textDirection: TextDirection.rtl,
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
      textDirection: TextDirection.rtl,
      children: [
        for (var i = 0; i < products.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _SimilarProductCard(product: products[i])),
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
                aspectRatio: 1.46,
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

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.cartCount});
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
          height: 66,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final route = items[i].route;
                      if (route == '/') {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      } else {
                        Navigator.pushNamed(context, route);
                      }
                    },
                    child: _NavItem(
                      icon: items[i].icon,
                      label: items[i].label,
                      selected: i == 0,
                      badge: items[i].badge,
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

class _NavItem extends StatelessWidget {
  const _NavItem({
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
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
