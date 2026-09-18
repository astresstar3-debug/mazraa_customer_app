import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mazraa_customer_app/core/state/app_controller.dart';
import 'package:mazraa_customer_app/features/marketplace/domain/marketplace_models.dart';
import 'package:mazraa_customer_app/features/marketplace/presentation/unified_product_details_screen.dart';
import 'package:mazraa_customer_app/main.dart' as app;

const bool _referenceVisual =
    bool.fromEnvironment('REFERENCE_VISUAL_TEST', defaultValue: false);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<AppController> waitForController(WidgetTester tester) async {
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 400));
      final materialApp = find.byType(MaterialApp);
      if (materialApp.evaluate().isNotEmpty) {
        return AppScope.of(tester.element(materialApp.first));
      }
    }
    throw TestFailure('Timed out waiting for the application controller.');
  }

  Future<Product> fetchRealServerProduct(AppController controller) async {
    try {
      final products = await controller.repository.fetchProducts();
      if (products.isEmpty) {
        throw TestFailure(
          'The real server returned no products; refusing to capture reference/mock data.',
        );
      }
      return products.first;
    } catch (error) {
      if (error is TestFailure) rethrow;
      throw TestFailure(
        'Failed to load a real product from the configured server: $error',
      );
    }
  }

  Future<void> precacheVisibleImages(WidgetTester tester) async {
    final elements = find.byType(Image).evaluate().toList(growable: false);
    for (final element in elements) {
      final widget = element.widget;
      if (widget is! Image) continue;
      try {
        await precacheImage(widget.image, element)
            .timeout(const Duration(seconds: 15));
      } catch (_) {}
    }
    await tester.pump(const Duration(milliseconds: 1200));
  }

  testWidgets(
    'capture only unified product details with real server data',
    (tester) async {
      if (_referenceVisual) {
        throw TestFailure(
          'REFERENCE_VISUAL_TEST must be disabled for the real-data product screenshot.',
        );
      }

      await app.main();

      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      final controller = await waitForController(tester);
      final product = await fetchRealServerProduct(controller);

      final navigator =
          tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => UnifiedProductDetailsScreen(product: product),
        ),
      );

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(seconds: 2));
      await precacheVisibleImages(tester);

      expect(find.byType(UnifiedProductDetailsScreen), findsOneWidget);

      final exception = tester.takeException();
      if (exception != null) {
        throw TestFailure('Product details UI exception: $exception');
      }

      await binding.takeScreenshot('product-details-real-server');
    },
  );
}
