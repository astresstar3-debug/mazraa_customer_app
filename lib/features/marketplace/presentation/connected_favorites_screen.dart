import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import 'connected_marketplace_screens.dart';

class ConnectedFavoritesScreen extends StatelessWidget {
  const ConnectedFavoritesScreen({super.key, this.forceEmpty = false});

  final bool forceEmpty;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    if (!app.isAuthenticated) {
      return Scaffold(
        appBar: const MazraaAppBar(title: 'المفضلة'),
        body: ResultStateView(
          kind: ResultKind.empty,
          title: 'سجّل الدخول لعرض المفضلة',
          message: 'تتم مزامنة المنتجات المفضلة مع حسابك على الخادم.',
          primaryLabel: 'تسجيل الدخول',
          onPrimary: () => Navigator.pushNamed(context, '/login'),
          secondaryLabel: 'تصفح المنتجات',
          onSecondary: () => Navigator.pushNamed(context, '/products'),
        ),
      );
    }

    final products = forceEmpty
        ? const <dynamic>[]
        : app.products.where((product) => app.isFavorite(product.id)).toList();

    return Scaffold(
      appBar: MazraaAppBar(title: 'المفضلة ${products.isEmpty ? '' : '(${products.length})'}'),
      body: products.isEmpty
          ? ResultStateView(
              kind: ResultKind.empty,
              title: 'لا توجد منتجات في المفضلة',
              message: 'اضغط على رمز القلب في أي منتج لإضافته إلى المفضلة.',
              primaryLabel: 'تصفح المنتجات',
              onPrimary: () => Navigator.pushNamed(context, '/products'),
            )
          : AppPage(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .62,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectedProductDetailsScreen(product: product),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
