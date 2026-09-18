import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mazraa_customer_app/core/state/app_controller.dart';
import 'package:mazraa_customer_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  AppController controllerOf(WidgetTester tester) {
    final appFinder = find.byType(MaterialApp);
    expect(appFinder, findsOneWidget);
    return AppScope.of(tester.element(appFinder.first));
  }

  Future<AppController> waitForRealHomeData(WidgetTester tester) async {
    final deadline = DateTime.now().add(const Duration(seconds: 45));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 500));
      final appFinder = find.byType(MaterialApp);
      if (appFinder.evaluate().isEmpty) continue;
      final controller = controllerOf(tester);
      if (!controller.isLoading &&
          !controller.client.hasPendingRequests &&
          controller.products.isNotEmpty) {
        final realProducts = await controller.repository.fetchProducts();
        if (realProducts.isEmpty) {
          throw TestFailure(
            'The real server returned no products; refusing to validate the home screen with reference/mock data.',
          );
        }
        await controller.refreshProducts();
        final ids = controller.products.map((item) => item.id).toSet();
        if (!ids.contains(realProducts.first.id)) {
          throw TestFailure(
            'Home screen products are not the real server products.',
          );
        }
        return controller;
      }
    }
    throw TestFailure('Timed out waiting for real home data.');
  }

  Future<void> precacheVisibleImages(WidgetTester tester) async {
    final elements = find.byType(Image).evaluate().toList(growable: false);
    for (final element in elements) {
      final widget = element.widget;
      if (widget is! Image) continue;
      try {
        await precacheImage(widget.image, element)
            .timeout(const Duration(seconds: 12));
      } catch (_) {}
    }
    await tester.pump(const Duration(milliseconds: 900));
  }

  Future<void> assertClean(WidgetTester tester, String stage) async {
    await tester.pump(const Duration(milliseconds: 250));
    final exception = tester.takeException();
    if (exception != null) {
      throw TestFailure('Home UI exception at $stage: $exception');
    }
  }

  Future<void> scrollUntilMounted(
    WidgetTester tester,
    Finder target, {
    int maxDrags = 14,
  }) async {
    final scroll = find.byKey(const ValueKey('home-main-scroll'));
    expect(scroll, findsOneWidget);

    for (var i = 0; i < maxDrags; i++) {
      if (target.evaluate().isNotEmpty) {
        await tester.ensureVisible(target);
        await tester.pump(const Duration(milliseconds: 400));
        return;
      }
      await tester.drag(scroll, const Offset(0, -520));
      await tester.pump(const Duration(milliseconds: 450));
    }
    throw TestFailure('Could not reach target on the home screen: $target');
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await precacheVisibleImages(tester);
    await assertClean(tester, name);
    await binding.takeScreenshot(name);
  }

  testWidgets(
    'match home, scroll products, and exercise all display modes with real data',
    (tester) async {
      await app.main();

      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      final controller = await waitForRealHomeData(tester);
      expect(controller.products, isNotEmpty);

      await capture(tester, 'home-reference-top-real');

      final couponAll =
          find.byKey(const ValueKey('home-coupons-view-all'));
      await scrollUntilMounted(tester, couponAll);
      expect(couponAll, findsOneWidget);
      await tester.tap(couponAll);
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        tester.state<NavigatorState>(find.byType(Navigator).first).canPop(),
        isTrue,
      );
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pump(const Duration(milliseconds: 450));
      await assertClean(tester, 'coupon view-all round trip');

      final bestList =
          find.byKey(const ValueKey('home-best-sellers-view-list'));
      await scrollUntilMounted(tester, bestList);
      await tester.tap(bestList);
      await tester.pump(const Duration(milliseconds: 350));
      await assertClean(tester, 'best sellers list');

      final bestCompact =
          find.byKey(const ValueKey('home-best-sellers-view-compact'));
      expect(bestCompact, findsOneWidget);
      await tester.tap(bestCompact);
      await tester.pump(const Duration(milliseconds: 350));
      await assertClean(tester, 'best sellers compact');

      final bestGrid =
          find.byKey(const ValueKey('home-best-sellers-view-grid'));
      expect(bestGrid, findsOneWidget);
      await tester.tap(bestGrid);
      await tester.pump(const Duration(milliseconds: 350));
      await assertClean(tester, 'best sellers grid');

      final allGrid =
          find.byKey(const ValueKey('home-all-products-view-grid'));
      await scrollUntilMounted(tester, allGrid);
      await capture(tester, 'home-products-grid-real');

      final allList =
          find.byKey(const ValueKey('home-all-products-view-list'));
      expect(allList, findsOneWidget);
      await tester.tap(allList);
      await tester.pump(const Duration(milliseconds: 500));
      await capture(tester, 'home-products-list-real');

      final allCompact =
          find.byKey(const ValueKey('home-all-products-view-compact'));
      expect(allCompact, findsOneWidget);
      await tester.tap(allCompact);
      await tester.pump(const Duration(milliseconds: 500));
      await capture(tester, 'home-products-compact-real');

      expect(
        find.byKey(const ValueKey('home-all-products-section')),
        findsOneWidget,
      );
      await assertClean(tester, 'final home validation');
    },
  );
}
