import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mazraa_customer_app/core/state/app_controller.dart';
import 'package:mazraa_customer_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final captureFailures = <String>[];

  bool hasIndeterminateLoadingIndicators() {
    final indicators = find.byWidgetPredicate((widget) {
      if (widget is RefreshProgressIndicator) return widget.value == null;
      if (widget is CircularProgressIndicator) return widget.value == null;
      if (widget is LinearProgressIndicator) return widget.value == null;
      return false;
    });
    return indicators.evaluate().isNotEmpty;
  }

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
        await precacheImage(widget.image, element).timeout(perImageTimeout);
      } catch (_) {
        // Capture only after the image has reached its final placeholder/error state.
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
      final uiException = tester.takeException();
      if (uiException != null) {
        throw TestFailure(
          'Unhandled UI exception while waiting for $screenName: $uiException',
        );
      }

      final controller = appController(tester);
      final loading = controller.isLoading ||
          controller.client.hasPendingRequests ||
          hasIndeterminateLoadingIndicators();

      if (!loading) {
        stableChecks++;
        if (stableChecks >= 3) {
          await precacheVisibleImages(tester);
          final settled = appController(tester);
          if (!settled.isLoading &&
              !settled.client.hasPendingRequests &&
              !hasIndeterminateLoadingIndicators()) {
            await tester.pump(const Duration(seconds: 1));
            final finalException = tester.takeException();
            if (finalException != null) {
              throw TestFailure(
                'Unhandled UI exception before capturing $screenName: $finalException',
              );
            }
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
      'visibleIndeterminateLoadingIndicators=${hasIndeterminateLoadingIndicators()}. '
      'Screenshot was not captured with incomplete data.',
    );
  }

  void drainUiExceptions(WidgetTester tester) {
    while (tester.takeException() != null) {
      // Drain already-recorded framework errors so one bad screen cannot block
      // diagnostics for every later screen. The error is still reported below.
    }
  }

  Future<void> capture(
    WidgetTester tester,
    String name, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    try {
      await waitUntilScreenReady(
        tester,
        screenName: name,
        timeout: timeout,
      );
    } catch (error, stackTrace) {
      captureFailures.add('$name: $error');
      debugPrint('VISUAL_CAPTURE_FAILURE [$name] $error');
      debugPrintStack(stackTrace: stackTrace);
      drainUiExceptions(tester);
      await tester.pump(const Duration(milliseconds: 250));
    }

    try {
      await binding.takeScreenshot(name);
    } catch (error) {
      captureFailures.add('$name screenshot: $error');
      debugPrint('SCREENSHOT_WRITE_FAILURE [$name] $error');
    }
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
      try {
        await openRoute(tester, entry.key);
        await capture(tester, entry.value);
      } catch (error, stackTrace) {
        captureFailures.add('${entry.value}: route/capture failed: $error');
        debugPrint('ROUTE_CAPTURE_FAILURE [${entry.key}] $error');
        debugPrintStack(stackTrace: stackTrace);
        drainUiExceptions(tester);
      }
    }
  }

  Future<void> captureOnboardingPages(WidgetTester tester) async {
    await openRoute(tester, '/onboarding');
    await capture(tester, 'onboarding-1');

    final nextButton = find.widgetWithText(FilledButton, 'التالي');
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, 'onboarding-2');

    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, 'onboarding-3');
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
      reason:
          'The disposable visual-test session must authenticate before protected screens are captured.',
    );
  }

  testWidgets('capture the complete customer app after real data is ready',
      (tester) async {
    await app.main();

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    await capture(tester, 'home-public');
    await captureOnboardingPages(tester);
    await captureRoutes(tester, const {
      '/register': 'auth-register',
      '/forgot-password': 'auth-forgot-password',
      '/reset-password': 'auth-reset-password',
      '/otp': 'auth-phone-verification',
      '/location-permission': 'location-permission',
      '/location': 'location-picker',
    });

    await loginTestAccount(tester);
    await openRoute(tester, '/');
    await capture(
      tester,
      'home-authenticated',
      timeout: const Duration(seconds: 70),
    );

    await captureRoutes(tester, const {
      '/categories': 'market-categories',
      '/search': 'market-search',
      '/search-results': 'market-search-results',
      '/search-empty': 'market-search-empty',
      '/products': 'market-products',
      '/product-list-view': 'market-products-list',
      '/offers': 'market-offers',
      '/product-filter': 'market-product-filter',
      '/coupon': 'market-coupons',
      '/product-details': 'product-details',
      '/product-medicine': 'product-medicine',
      '/product-feed': 'product-feed',
      '/reviews': 'product-reviews',
      '/ask-question': 'product-question',
      '/favorites': 'favorites',
      '/favorites-empty': 'favorites-empty',
      '/favorites-plant-empty': 'favorites-plant-empty',
    });

    await captureRoutes(tester, const {
      '/auctions': 'auctions-list',
      '/auction-filter': 'auction-filter',
      '/auction-details': 'auction-details',
      '/auction-details-crop': 'auction-details-crop',
      '/auction-details-equipment': 'auction-details-equipment',
      '/auction-gallery': 'auction-gallery',
      '/auction-bid': 'auction-bid',
      '/auction-bid-confirm': 'auction-bid-confirm',
      '/auction-settlement': 'auction-settlement',
      '/auction-success': 'auction-success',
      '/auction-won': 'auction-won',
      '/auction-ended': 'auction-ended',
      '/my-auctions': 'my-auctions',
      '/bid-history': 'bid-history',
      '/auction-reminder': 'auction-reminder',
      '/guarantee-details': 'auction-guarantee',
    });

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

    if (captureFailures.isNotEmpty) {
      throw TestFailure(
        'Visual capture completed with ${captureFailures.length} failure(s):\n'
        '${captureFailures.join('\n')}',
      );
    }
  });
}
