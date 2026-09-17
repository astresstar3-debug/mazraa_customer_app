import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mazraa_customer_app/core/state/app_controller.dart';
import 'package:mazraa_customer_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitForProducts(WidgetTester tester) async {
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 400));
      final materialApp = find.byType(MaterialApp);
      if (materialApp.evaluate().isEmpty) continue;
      final controller = AppScope.of(tester.element(materialApp.first));
      if (!controller.isLoading && controller.products.isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for product data.');
  }

  Future<void> precacheVisibleImages(WidgetTester tester) async {
    final elements = find.byType(Image).evaluate().toList(growable: false);
    for (final element in elements) {
      final widget = element.widget;
      if (widget is! Image) continue;
      try {
        await precacheImage(widget.image, element)
            .timeout(const Duration(seconds: 10));
      } catch (_) {}
    }
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('capture only the unified product details screen', (tester) async {
    await app.main();

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    await waitForProducts(tester);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    navigator.pushNamed('/product-details');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 1));
    await precacheVisibleImages(tester);

    final exception = tester.takeException();
    if (exception != null) {
      throw TestFailure('Product details UI exception: $exception');
    }

    await binding.takeScreenshot('product-details');
  });
}
