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
    return AppScope.of(tester.element(materialApp.first));
  }

  Future<void> precacheVisibleImages(
    WidgetTester tester, {
    Duration perImageTimeout = const Duration(seconds: 12),
  }) async {
    final elements = find.byType(Image).evaluate().toList(growable: false);
    for (final element in elements) {
      final widget = element.widget;
      if (widget is! Image) continue;
      try {
        await precacheImage(widget.image, element)
            .timeout(perImageTimeout);
      } catch (_) {
        // A failed remote image must resolve to the app's error/placeholder UI.
        // The screenshot should never be taken while the image is still pending.
      }
    }
    await tester.pump(const Duration(milliseconds: 700));
  }

  Future<void> waitUntilScreenReady(
    WidgetTester tester, {
    required String screenName,
    Duration timeout = const Duration(seconds: 45),
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
          await precacheVisibleImages(tester);
          final settled = appController(tester);
          if (!settled.isLoading &&
              !settled.client.hasPendingRequests &&
              !hasLoadingIndicators()) {
            // Give decoded images and final text/layout one last paint cycle.
            await tester.pump(const Duration(seconds: 1));
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
      'Timed out waiting for $screenName. '
      'appLoading=${controller.isLoading}, '
      'pendingApiRequests=${controller.client.activeRequestCount}, '
      'visibleLoadingIndicators=${hasLoadingIndicators()}. '
      'Screenshot was not captured with incomplete data.',
    );
  }

  Future<void> capture(
    WidgetTester tester,
    String name, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    await waitUntilScreenReady(
      tester,
      screenName: name,
      timeout: timeout,
    );
    final exception = tester.takeException();
    if (exception != null) {
      throw TestFailure('Unhandled UI exception on $name: $exception');
    }
    await binding.takeScreenshot(name);
  }

  Future<void> openRoute(
    WidgetTester tester,
    String route, {
    Duration settle = const Duration(milliseconds: 250),
  }) async {
    final navigatorFinder = find.byType(Navigator);
    expect(navigatorFinder, findsWidgets);
    final navigator = tester.state<NavigatorState>(navigatorFinder.first);
    navigator.pushNamedAndRemoveUntil(route, (candidate) => candidate.isFirst);
    await tester.pump(settle);
  }

  Future<void> captureRoutes(
    WidgetTester tester,
    Map<String, String> routes,
  ) async {
    for (final entry in routes.entries) {
      await openRoute(tester, entry.key);
      await capture(tester, entry.value);
    }
  }

  Future<void> loginTestAccount(WidgetTester tester) async {
    await openRoute(tester, '/login');
    await capture(tester, 'auth-login');

    final fields = find.byType(TextField);
    expect(fields, findsAtLeastNWidgets(2));
    await tester.enterText(fields.at(0), 'b@b.com');
    await tester.enterText(fields.at(1), 'b1234567');
    await tester.pump();

    final submit = find.widgetWithText(FilledButton, 'تسجيل الدخول');
    expect(submit, findsOneWidget);
    await tester.tap(submit);
    await tester.pump();
    await waitUntilScreenReady(
      tester,
      screenName: 'authenticated-session',
      timeout: const Duration(seconds: 70),
    );

    final controller = appController(tester);
    expect(
      controller.isAuthenticated,
      isTrue,
      reason: 'The disposable integration-test account must authenticate before protected screens are captured.',
    );
  }

  testWidgets('capture the complete customer app after real data is ready',
      (tester) async {
    await app.main();

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    // Public/reference flows first.
    await capture(tester, 'home-public');
    await captureRoutes(tester, const {
      '/onboarding': 'onboarding',
      '/register': 'auth-register',
      '/forgot-password': 'auth-forgot-password',
      '/reset-password': 'auth-reset-password',
      '/otp': 'auth-phone-verification',
      '/location-permission': 'location-permission',
      '/location': 'location-picker',
    });

    // Continue the same emulator/app process using the disposable test account.
    await loginTestAccount(tester);
    await openRoute(tester, '/');
    await capture(tester, 'home-authenticated', timeout: const Duration(seconds: 70));

    // Marketplace and product flows.
    await captureRoutes(tester, const {
      '/categories': 'market-categories',
      '/search': 'market-search',
      '/products': 'market-products',
      '/offers': 'market-offers',
      '/coupon': 'market-coupons',
      '/product-details': 'product-details',
      '/product-medicine': 'product-medicine',
      '/product-feed': 'product-feed',
      '/reviews': 'product-reviews',
      '/ask-question': 'product-question',
      '/favorites': 'favorites',
      '/favorites-empty': 'favorites-empty',
    });

    // Auctions, including UI-only reference states when the backend has no endpoint yet.
    await captureRoutes(tester, const {
      '/auctions': 'auctions-list',
      '/auction-details': 'auction-details',
      '/auction-gallery': 'auction-gallery',
      '/auction-bid': 'auction-bid',
      '/auction-success': 'auction-success',
      '/auction-won': 'auction-won',
      '/auction-ended': 'auction-ended',
      '/my-auctions': 'my-auctions',
      '/bid-history': 'bid-history',
      '/auction-reminder': 'auction-reminder',
      '/guarantee-details': 'auction-guarantee',
    });

    // Cart, checkout and payment states.
    await captureRoutes(tester, const {
      '/cart': 'cart',
      '/cart-empty': 'cart-empty',
      '/checkout': 'checkout',
      '/delivery-slot': 'delivery-slot',
      '/delivery-preferences': 'delivery-preferences',
      '/payment-methods': 'payment-methods',
      '/add-card': 'payment-add-card',
      '/edit-payment': 'payment-edit',
      '/cash-on-delivery': 'payment-cash-on-delivery',
      '/bank-transfer': 'payment-bank-transfer',
      '/order-success': 'order-success',
      '/payment-success': 'payment-success',
      '/payment-failed': 'payment-failed',
      '/wallet-pending': 'wallet-pending',
    });

    // Account, addresses, wallet, orders, returns and support.
    await captureRoutes(tester, const {
      '/account': 'account',
      '/edit-profile': 'account-edit-profile',
      '/profile-avatar': 'account-avatar',
      '/change-phone': 'account-change-phone',
      '/change-password': 'account-change-password',
      '/settings': 'settings',
      '/notifications': 'notifications',
      '/notification-preferences': 'notification-preferences',
      '/addresses': 'addresses',
      '/addresses-empty': 'addresses-empty',
      '/add-address': 'address-add',
      '/wallet': 'wallet',
      '/wallet-topup': 'wallet-topup',
      '/wallet-topup-success': 'wallet-topup-success',
      '/wallet-transactions': 'wallet-transactions',
      '/orders': 'orders',
      '/order-details': 'order-details',
      '/track-order': 'order-tracking',
      '/cancel-order': 'order-cancel',
      '/order-cancelled': 'order-cancelled',
      '/rate-order': 'order-rating',
      '/returns': 'returns',
      '/return-request': 'return-request',
      '/return-success': 'return-success',
      '/refund-status': 'refund-status',
      '/invoice': 'invoice',
      '/support': 'support',
      '/support-ticket': 'support-ticket',
      '/support-chat': 'support-chat',
      '/legal': 'legal',
      '/delete-account': 'delete-account',
      '/offline': 'offline',
    });
  });
}
