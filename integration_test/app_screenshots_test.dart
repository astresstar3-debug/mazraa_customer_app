import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mazraa_customer_app/core/state/app_controller.dart';
import 'package:mazraa_customer_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  bool hasLoadingIndicators() =>
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
      find.byType(LinearProgressIndicator).evaluate().isNotEmpty ||
      find.byType(RefreshProgressIndicator).evaluate().isNotEmpty;

  AppController appController(WidgetTester tester) {
    final materialApp = find.byType(MaterialApp);
    expect(materialApp, findsOneWidget);
    final context = tester.element(materialApp.first);
    return AppScope.of(context);
  }

  Future<void> waitUntilScreenReady(
    WidgetTester tester, {
    required String screenName,
    Duration timeout = const Duration(seconds: 35),
  }) async {
    await tester.pump();

    final deadline = DateTime.now().add(timeout);
    var stableChecks = 0;

    while (DateTime.now().isBefore(deadline)) {
      final controller = appController(tester);
      final loading = controller.isLoading ||
          controller.client.hasPendingRequests ||
          hasLoadingIndicators();

      if (!loading) {
        stableChecks++;
        if (stableChecks >= 3) {
          // Give network images and the final layout extra time to settle.
          await tester.pump(const Duration(seconds: 2));

          final settledController = appController(tester);
          if (!settledController.isLoading &&
              !settledController.client.hasPendingRequests &&
              !hasLoadingIndicators()) {
            return;
          }
          stableChecks = 0;
        }
      } else {
        stableChecks = 0;
      }

      await tester.pump(const Duration(milliseconds: 500));
    }

    final controller = appController(tester);
    throw TestFailure(
      'Timed out waiting for $screenName to finish loading. '
      'appLoading=${controller.isLoading}, '
      'pendingApiRequests=${controller.client.activeRequestCount}, '
      'visibleLoadingIndicators=${hasLoadingIndicators()}. '
      'Screenshot was intentionally not captured while data was incomplete.',
    );
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await waitUntilScreenReady(tester, screenName: name);

    final exception = tester.takeException();
    if (exception != null) {
      throw TestFailure('Unhandled UI exception on $name: $exception');
    }

    await binding.takeScreenshot(name);
  }

  Future<void> openRoute(WidgetTester tester, String route) async {
    final navigatorFinder = find.byType(Navigator);
    expect(navigatorFinder, findsWidgets);
    final navigator = tester.state<NavigatorState>(navigatorFinder.first);
    navigator.pushNamedAndRemoveUntil(route, (candidate) => candidate.isFirst);
    await tester.pump();
  }

  testWidgets('launch public app screens and capture screenshots', (tester) async {
    await app.main();

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    await capture(tester, '01-home');

    const routes = <String, String>{
      '/categories': '02-categories',
      '/search': '03-search',
      '/products': '04-products',
      '/offers': '05-offers',
      '/auctions': '06-auctions',
      '/cart': '07-cart',
      '/account': '08-account',
      '/login': '09-login',
      '/register': '10-register',
    };

    for (final entry in routes.entries) {
      await openRoute(tester, entry.key);
      await capture(tester, entry.value);
    }

    await openRoute(tester, '/coupon');
    await capture(tester, '11-coupons');

    final couponDetailArrow = find.byIcon(Icons.arrow_back_rounded);
    if (couponDetailArrow.evaluate().isNotEmpty) {
      await tester.tap(couponDetailArrow.last);
      await tester.pump();
      await capture(tester, '11b-coupon-detail');
    }

    await openRoute(tester, '/legal');
    await capture(tester, '12-legal');
  });
}
