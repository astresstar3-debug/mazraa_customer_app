import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'unified_product_details_screen.dart';

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
                  child: Text(
                    'اكتب اسم المنتج أو كلمة من الوصف ثم اضغط بحث.',
                    textAlign: TextAlign.center,
                  ),
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
  State<ConnectedProductListScreen> createState() =>
      _ConnectedProductListScreenState();
}

class _ConnectedProductListScreenState extends State<ConnectedProductListScreen> {
  String sort = 'best_selling';

  @override
  Widget build(BuildContext context) {
    final source = AppScope.of(context).products;
    final products = source.where((product) {
      if (widget.category != null && product.category != widget.category) {
        return false;
      }
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
                    DropdownMenuItem(
                      value: 'best_selling',
                      child: Text('الأكثر مبيعًا'),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('السعر: الأقل أولًا'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('السعر: الأعلى أولًا'),
                    ),
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
              builder: (_) =>
                  UnifiedProductDetailsScreen(product: products[index]),
            ),
          ),
        ),
      );
}

/// Compatibility wrapper kept for the existing callers.
/// Every product kind now renders the same unified details design.
class ConnectedProductDetailsScreen extends StatelessWidget {
  const ConnectedProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) =>
      UnifiedProductDetailsScreen(product: product);
}
