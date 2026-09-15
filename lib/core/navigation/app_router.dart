import 'package:flutter/material.dart';

import '../../features/account/presentation/account_screens.dart';
import '../../features/account/presentation/connected_account_data_screens.dart';
import '../../features/account/presentation/connected_account_screen.dart';
import '../../features/account/presentation/connected_customer_service_screens.dart';
import '../../features/account/presentation/connected_delete_account_screen.dart';
import '../../features/account/presentation/connected_support_chat_screen.dart';
import '../../features/account/presentation/misc_screens.dart';
import '../../features/auctions/presentation/connected_auction_screens.dart';
import '../../features/auctions/presentation/connected_my_auctions_screen.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/connected_auth_screens.dart';
import '../../features/auth/presentation/connected_recovery_screens.dart';
import '../../features/cart/presentation/connected_cart_screens.dart';
import '../../features/marketplace/presentation/connected_marketplace_screens.dart';
import '../../features/marketplace/presentation/connected_product_reviews_screen.dart';
import '../../features/marketplace/presentation/marketplace_screens.dart';
import '../../features/shell/main_shell.dart';
import '../../shared/widgets/mazraa_widgets.dart';
import '../state/app_controller.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      '/' => const MainShell(),
      '/onboarding' => const OnboardingScreen(),
      '/login' => const ConnectedLoginScreen(),
      '/register' => const ConnectedRegisterScreen(),
      '/forgot-password' => const ConnectedForgotPasswordScreen(),
      '/reset-password' => const ConnectedResetPasswordScreen(),
      '/otp' => const ConnectedResetPasswordScreen(),
      '/location-permission' => const ConnectedAddressesScreen(),
      '/location' => const ConnectedAddressesScreen(),
      '/categories' => const ConnectedCategoriesScreen(),
      '/search' => const ConnectedSearchScreen(),
      '/products' => const ConnectedProductListScreen(),
      '/offers' => const ConnectedProductListScreen(title: 'العروض', onlyOffers: true),
      '/coupon' => const ConnectedProductListScreen(title: 'العروض', onlyOffers: true),
      '/product-details' => const _FirstProductScreen(),
      '/product-medicine' => const _FirstProductScreen(index: 7),
      '/product-feed' => const _FirstProductScreen(index: 3),
      '/reviews' => const _ReviewRoute(),
      '/ask-question' => const _AskRoute(),
      '/favorites' => const FavoritesScreen(),
      '/favorites-empty' => const FavoritesScreen(empty: true),
      '/auctions' => const ConnectedAuctionListScreen(),
      '/auction-details' => const _FirstAuctionScreen(),
      '/auction-gallery' => const _FirstAuctionScreen(index: 2),
      '/auction-bid' => const _BidRoute(),
      '/auction-success' => const _FirstAuctionScreen(),
      '/auction-won' => const ConnectedMyAuctionsScreen(),
      '/auction-ended' => const ConnectedMyAuctionsScreen(),
      '/my-auctions' => const ConnectedMyAuctionsScreen(),
      '/bid-history' => const ConnectedMyAuctionsScreen(historyOnly: true),
      '/auction-reminder' => const _ServerFeatureUnavailableScreen(
        title: 'تذكير المزاد',
        message: 'لا يوجد في نسخة السيرفر الحالية endpoint لحفظ تذكيرات المزادات، لذلك لن يعرض التطبيق نجاحًا محليًا وهميًا.',
      ),
      '/guarantee-details' => const _ServerFeatureUnavailableScreen(
        title: 'ضمان المزاد',
        message: 'لا يوجد في نسخة السيرفر الحالية endpoint مستقل لضمان المزاد. لن يعرض التطبيق مبلغ ضمان تجريبيًا.',
      ),
      '/cart' => const ConnectedCartScreen(),
      '/cart-empty' => const ConnectedCartScreen(forceEmpty: true),
      '/checkout' => const ConnectedCheckoutScreen(),
      '/delivery-slot' => const ConnectedCheckoutScreen(),
      '/delivery-preferences' => const ConnectedCheckoutScreen(),
      '/payment-methods' => const ConnectedPaymentMethodsScreen(),
      '/add-card' => const ConnectedPaymentMethodsScreen(),
      '/edit-payment' => const ConnectedPaymentMethodsScreen(),
      '/cash-on-delivery' => const ConnectedPaymentMethodsScreen(),
      '/bank-transfer' => const ConnectedPaymentMethodsScreen(),
      '/order-success' => const ConnectedOrdersScreen(),
      '/payment-success' => const ConnectedOrdersScreen(),
      '/payment-failed' => const ConnectedCheckoutScreen(),
      '/wallet-pending' => const ConnectedWalletScreen(),
      '/account' => const ConnectedAccountScreen(),
      '/edit-profile' => const ConnectedEditProfileScreen(),
      '/change-phone' => const ConnectedEditProfileScreen(),
      '/change-password' => const ConnectedChangePasswordScreen(),
      '/settings' => const ConnectedSettingsScreen(),
      '/notifications' => const ConnectedNotificationsScreen(),
      '/notification-preferences' => const ConnectedNotificationPreferencesScreen(),
      '/addresses' => const ConnectedAddressesScreen(),
      '/addresses-empty' => const ConnectedAddressesScreen(),
      '/add-address' => const ConnectedAddressFormScreen(),
      '/wallet' => const ConnectedWalletScreen(),
      '/wallet-topup' => const ConnectedWalletTopUpScreen(),
      '/wallet-topup-success' => const ConnectedWalletScreen(),
      '/wallet-transactions' => const ConnectedWalletTransactionsScreen(),
      '/orders' => const ConnectedOrdersScreen(),
      '/order-details' => const _FirstOrderActionRoute(action: _OrderAction.details),
      '/track-order' => const _FirstOrderActionRoute(action: _OrderAction.track),
      '/cancel-order' => const _FirstOrderActionRoute(action: _OrderAction.cancel),
      '/order-cancelled' => const ConnectedOrdersScreen(),
      '/rate-order' => const _FirstOrderActionRoute(action: _OrderAction.rate),
      '/returns' => const ConnectedReturnsScreen(),
      '/return-request' => const _FirstOrderActionRoute(action: _OrderAction.returnOrder),
      '/return-success' => const ConnectedReturnsScreen(),
      '/refund-status' => const ConnectedReturnsScreen(),
      '/invoice' => const _FirstOrderActionRoute(action: _OrderAction.details),
      '/support' => const ConnectedSupportScreen(),
      '/support-ticket' => const ConnectedSupportTicketScreen(),
      '/support-chat' => const ConnectedSupportChatScreen(),
      '/legal' => const LegalScreen(),
      '/delete-account' => const ConnectedDeleteAccountScreen(),
      '/offline' => const GenericActionResultScreen(
        title: 'لا يوجد اتصال بالإنترنت',
        message: 'تحقق من اتصالك وحاول مرة أخرى.',
        kind: ResultKind.offline,
      ),
      _ => const MainShell(),
    };
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }
}

class _FirstProductScreen extends StatelessWidget {
  const _FirstProductScreen({this.index = 0});
  final int index;

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    if (products.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد منتجات',
          message: 'لم يعرض الخادم منتجات متاحة حاليًا.',
          kind: ResultKind.empty,
        ),
      );
    }
    final safeIndex = index < 0 ? 0 : (index >= products.length ? products.length - 1 : index);
    return ConnectedProductDetailsScreen(product: products[safeIndex]);
  }
}

class _ReviewRoute extends StatelessWidget {
  const _ReviewRoute();

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    if (products.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد منتجات',
          message: 'لا توجد بيانات تقييم متاحة.',
          kind: ResultKind.empty,
        ),
      );
    }
    return ConnectedProductReviewsScreen(product: products.first);
  }
}

class _AskRoute extends StatelessWidget {
  const _AskRoute();

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    if (products.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد منتجات',
          message: 'لا يوجد منتج متاح لعرض الأسئلة.',
          kind: ResultKind.empty,
        ),
      );
    }
    return ConnectedProductQuestionsScreen(product: products.first);
  }
}

class _FirstAuctionScreen extends StatelessWidget {
  const _FirstAuctionScreen({this.index = 0});
  final int index;

  @override
  Widget build(BuildContext context) {
    final auctions = AppScope.of(context).auctions;
    if (auctions.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد مزادات',
          message: 'لم يعرض الخادم مزادات متاحة حاليًا.',
          kind: ResultKind.empty,
        ),
      );
    }
    final safeIndex = index < 0 ? 0 : (index >= auctions.length ? auctions.length - 1 : index);
    return ConnectedAuctionDetailsScreen(auction: auctions[safeIndex]);
  }
}

class _BidRoute extends StatelessWidget {
  const _BidRoute();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.auctions.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد مزادات',
          message: 'لا يوجد مزاد متاح للمزايدة الآن.',
          kind: ResultKind.empty,
        ),
      );
    }
    if (!app.isAuthenticated) return const ConnectedLoginScreen();
    return ConnectedBidScreen(auction: app.auctions.first);
  }
}

enum _OrderAction { details, track, cancel, rate, returnOrder }

class _FirstOrderActionRoute extends StatelessWidget {
  const _FirstOrderActionRoute({required this.action});
  final _OrderAction action;

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).orders;
    if (orders.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد طلبات',
          message: 'لا يوجد طلب متاح لهذه العملية.',
          kind: ResultKind.empty,
        ),
      );
    }
    final id = int.tryParse(orders.first.id) ?? 0;
    if (id <= 0) {
      return const Scaffold(
        body: ResultStateView(
          title: 'تعذر فتح الطلب',
          message: 'رقم الطلب غير صالح.',
          kind: ResultKind.error,
        ),
      );
    }
    return switch (action) {
      _OrderAction.details => ConnectedOrderDetailsScreen(orderId: id),
      _OrderAction.track => ConnectedTrackOrderScreen(orderId: id),
      _OrderAction.cancel => ConnectedCancelOrderScreen(orderId: id),
      _OrderAction.rate => ConnectedRateOrderScreen(orderId: id),
      _OrderAction.returnOrder => ConnectedReturnRequestScreen(orderId: id),
    };
  }
}

class _ServerFeatureUnavailableScreen extends StatelessWidget {
  const _ServerFeatureUnavailableScreen({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MazraaAppBar(title: title),
        body: ResultStateView(
          kind: ResultKind.empty,
          title: title,
          message: message,
          primaryLabel: 'العودة للمزادات',
          onPrimary: () => Navigator.pushReplacementNamed(context, '/auctions'),
        ),
      );
}
