import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'connected_product_reviews_screen.dart';

class ConnectedCategoriesScreen extends StatelessWidget {
  const ConnectedCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final categories = app.categories;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'الأقسام'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (app.isLoading && categories.isEmpty)
              const LinearProgressIndicator(),
            if (categories.isEmpty && !app.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: Text('لا توجد أقسام متاحة حاليًا')),
              )
            else
              ...categories.map((category) {
                final count = app.products.where((p) => p.category == category).length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: SettingsTile(
                    icon: Icons.category_outlined,
                    title: category,
                    subtitle: '$count منتج',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectedProductListScreen(
                          title: category,
                          category: category,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class ConnectedSearchScreen extends StatefulWidget {
  const ConnectedSearchScreen({super.key});

  @override
  State<ConnectedSearchScreen> createState() => _ConnectedSearchScreenState();
}

class _ConnectedSearchScreenState extends State<ConnectedSearchScreen> {
  final controller = TextEditingController();
  List<Product> results = const [];
  bool loading = false;
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        results = const [];
        error = null;
      });
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await AppScope.of(context).repository.fetchProducts(query: query);
      if (mounted) setState(() => results = data);
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر تنفيذ البحث.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'البحث'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'ابحث عن المنتجات...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => _search(controller.text),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (loading) const LinearProgressIndicator(),
              if (error != null)
                AppSurfaceCard(child: Text(error!, textAlign: TextAlign.center)),
              if (!loading && controller.text.trim().isEmpty)
                const AppSurfaceCard(
                  child: Text('اكتب اسم المنتج أو كلمة من الوصف ثم اضغط بحث.',
                      textAlign: TextAlign.center),
                )
              else if (!loading && error == null && results.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: Text('لا توجد نتائج مطابقة')),
                )
              else
                _ProductsGrid(products: results),
            ],
          ),
        ),
      );
}

class ConnectedProductListScreen extends StatefulWidget {
  const ConnectedProductListScreen({
    super.key,
    this.title = 'المنتجات',
    this.category,
    this.onlyOffers = false,
  });

  final String title;
  final String? category;
  final bool onlyOffers;

  @override
  State<ConnectedProductListScreen> createState() => _ConnectedProductListScreenState();
}

class _ConnectedProductListScreenState extends State<ConnectedProductListScreen> {
  String sort = 'best_selling';

  @override
  Widget build(BuildContext context) {
    final source = AppScope.of(context).products;
    final products = source.where((product) {
      if (widget.category != null && product.category != widget.category) return false;
      if (widget.onlyOffers && product.discount == null) return false;
      return true;
    }).toList();

    if (sort == 'price_asc') {
      products.sort((a, b) => a.price.compareTo(b.price));
    } else if (sort == 'price_desc') {
      products.sort((a, b) => b.price.compareTo(a.price));
    } else {
      products.sort((a, b) => b.sales.compareTo(a.sales));
    }

    return Scaffold(
      appBar: MazraaAppBar(title: widget.title),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('${products.length} منتج'),
                const Spacer(),
                DropdownButton<String>(
                  value: sort,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'best_selling', child: Text('الأكثر مبيعًا')),
                    DropdownMenuItem(value: 'price_asc', child: Text('السعر: الأقل أولًا')),
                    DropdownMenuItem(value: 'price_desc', child: Text('السعر: الأعلى أولًا')),
                  ],
                  onChanged: (value) => setState(() => sort = value ?? sort),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: Text('لا توجد منتجات متاحة')),
              )
            else
              _ProductsGrid(products: products),
          ],
        ),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: .62,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, index) => ProductCard(
          product: products[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConnectedProductDetailsScreen(product: products[index]),
            ),
          ),
        ),
      );
}

class ConnectedProductDetailsScreen extends StatefulWidget {
  const ConnectedProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ConnectedProductDetailsScreen> createState() =>
      _ConnectedProductDetailsScreenState();
}

class _ConnectedProductDetailsScreenState extends State<ConnectedProductDetailsScreen> {
  int quantity = 1;
  int imageIndex = 0;
  bool adding = false;
  bool loadingExtras = true;
  String? extrasError;
  List<Map<String, dynamic>> specs = const [];
  List<Product> related = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadingExtras && specs.isEmpty && related.isEmpty && extrasError == null) {
      _loadExtras();
    }
  }

  Future<void> _loadExtras() async {
    final productId = int.tryParse(widget.product.id);
    if (productId == null) {
      setState(() {
        loadingExtras = false;
        extrasError = 'رقم المنتج غير صالح.';
      });
      return;
    }
    try {
      final app = AppScope.of(context);
      final values = await Future.wait<dynamic>([
        app.client.get('/api/products/$productId/specs'),
        app.client.get('/api/products/$productId/related'),
      ]);
      final specRows = values[0] is List
          ? (values[0] as List).map((e) => jsonMap(e)).toList()
          : <Map<String, dynamic>>[];
      final relatedRows = values[1] is List ? values[1] as List : const [];
      final known = <String, Product>{for (final p in app.products) p.id: p};
      final relatedProducts = <Product>[];
      for (final row in relatedRows) {
        final map = jsonMap(row);
        final id = '${jsonValue(map, 'id') ?? ''}';
        final product = known[id];
        if (product != null) relatedProducts.add(product);
      }
      if (!mounted) return;
      setState(() {
        specs = specRows;
        related = relatedProducts;
      });
    } catch (e) {
      if (mounted) {
        setState(() => extrasError = e is ApiException ? e.message : 'تعذر تحميل بيانات المنتج الإضافية.');
      }
    } finally {
      if (mounted) setState(() => loadingExtras = false);
    }
  }

  Future<void> _add({bool checkout = false}) async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.errorMessage ?? 'تعذر إضافة المنتج للسلة')),
        );
      }
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final app = AppScope.of(context);
    final gallery = product.images.isEmpty ? [product.image] : product.images;
    final selectedImage = gallery[imageIndex < gallery.length ? imageIndex : 0];

    return Scaffold(
      appBar: MazraaAppBar(
        title: 'تفاصيل المنتج',
        actions: [
          IconButton(
            onPressed: () async {
              if (!app.isAuthenticated) {
                Navigator.pushNamed(context, '/login');
                return;
              }
              await app.toggleFavorite(product.id);
            },
            icon: Icon(
              app.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
              color: AppColors.terracotta,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: adding || !product.inStock ? null : () => _add(),
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('أضف للسلة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: adding || !product.inStock ? null : () => _add(checkout: true),
                  child: adding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('شراء الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AppDataImage(selectedImage, fit: BoxFit.cover),
              ),
            ),
            if (gallery.length > 1) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 62,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: gallery.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 7),
                  itemBuilder: (_, index) => InkWell(
                    onTap: () => setState(() => imageIndex = index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: AppDataImage(
                        gallery[index],
                        width: 74,
                        height: 62,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatPrice(product.price),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.forest),
                      ),
                      if (product.oldPrice != null)
                        Text(
                          formatPrice(product.oldPrice!),
                          style: const TextStyle(
                            color: AppColors.muted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (product.discount != null)
                        StatusPill(
                          label: 'خصم ${product.discount}%',
                          color: AppColors.terracotta,
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFE5A72D), size: 18),
                      Text(' ${product.rating}'),
                      const Spacer(),
                      StatusPill(
                        label: product.inStock ? 'متوفر' : 'غير متوفر',
                        color: product.inStock ? AppColors.forest : AppColors.terracotta,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SectionHeader(title: 'الكمية', icon: Icons.numbers_rounded),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: QuantityStepper(
                value: quantity,
                onChanged: (value) {
                  if (value >= 1) setState(() => quantity = value);
                },
              ),
            ),
            const SizedBox(height: 14),
            const SectionHeader(title: 'الوصف', icon: Icons.description_outlined),
            AppSurfaceCard(
              child: Text(
                product.description.trim().isEmpty
                    ? 'لا يوجد وصف إضافي لهذا المنتج.'
                    : product.description,
              ),
            ),
            const SizedBox(height: 14),
            const SectionHeader(title: 'المواصفات', icon: Icons.fact_check_outlined),
            if (loadingExtras)
              const LinearProgressIndicator()
            else if (specs.isEmpty)
              const AppSurfaceCard(child: Text('لا توجد مواصفات إضافية لهذا المنتج.'))
            else
              AppSurfaceCard(
                child: Column(
                  children: specs.map((spec) {
                    final name = '${jsonValue(spec, 'name') ?? ''}';
                    final value = '${jsonValue(spec, 'value') ?? ''}';
                    final unit = '${jsonValue(spec, 'unit') ?? ''}';
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(name),
                      trailing: Text('$value${unit.isEmpty ? '' : ' $unit'}'),
                    );
                  }).toList(),
                ),
              ),
            if (extrasError != null) ...[
              const SizedBox(height: 7),
              Text(extrasError!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectedProductReviewsScreen(product: product),
                      ),
                    ),
                    icon: const Icon(Icons.star_outline_rounded),
                    label: const Text('التقييمات'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectedProductQuestionsScreen(product: product),
                      ),
                    ),
                    icon: const Icon(Icons.help_outline_rounded),
                    label: const Text('الأسئلة'),
                  ),
                ),
              ],
            ),
            if (related.isNotEmpty) ...[
              const SizedBox(height: 16),
              const SectionHeader(title: 'منتجات مشابهة', icon: Icons.grid_view_rounded),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, index) => SizedBox(
                    width: 180,
                    child: ProductCard(
                      product: related[index],
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectedProductDetailsScreen(product: related[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
