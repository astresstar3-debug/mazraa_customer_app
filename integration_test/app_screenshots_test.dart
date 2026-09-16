import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mazraa_customer_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settleNetworkScreen(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
  }

  Future<void> waitForLoadingToFinish(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 14),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end) &&
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await settleNetworkScreen(tester);
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
    await waitForLoadingToFinish(tester);
    await capture(tester, '11-coupons');

    final couponDetailArrow = find.byIcon(Icons.arrow_back_rounded);
    if (couponDetailArrow.evaluate().isNotEmpty) {
      await tester.tap(couponDetailArrow.last);
      await tester.pump();
      await waitForLoadingToFinish(tester);
      await capture(tester, '11b-coupon-detail');
    }

    await openRoute(tester, '/legal');
    await capture(tester, '12-legal');
  });
}
