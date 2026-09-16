import 'package:flutter/material.dart';

import '../../features/account/presentation/account_screens.dart';
import '../../features/account/presentation/connected_account_data_screens.dart';
import '../../features/account/presentation/connected_account_screen.dart';
import '../../features/account/presentation/connected_customer_service_screens.dart';
import '../../features/account/presentation/connected_delete_account_screen.dart';
import '../../features/account/presentation/connected_responsive_wallet_screen.dart';
import '../../features/account/presentation/connected_server_account_extras.dart';
import '../../features/account/presentation/connected_support_chat_screen.dart';
import '../../features/auctions/presentation/reference_auction_screens.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/connected_auth_screens.dart';
import '../../features/auth/presentation/connected_phone_verification_screen.dart';
import '../../features/auth/presentation/connected_recovery_screens.dart';
import '../../features/cart/presentation/cart_screens.dart';
import '../../features/cart/presentation/connected_cart_screens.dart';
import '../../features/cart/presentation/connected_coupons_screen.dart';
import '../../features/cart/presentation/connected_enhanced_checkout_screen.dart';
import '../../features/marketplace/presentation/reference_marketplace_screens.dart';
import '../../features/marketplace/presentation/reference_product_screens.dart';
import '../../features/shell/main_shell.dart';
import '../../shared/widgets/mazraa_widgets.dart';
import '../reference/reference_demo_data.dart';
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
      '/otp' => const ConnectedPhoneVerificationScreen(),
      '/location-permission' => const LocationPermissionScreen(),
      '/location' => const LocationScreen(),
      '/categories' => const ReferenceCategoriesScreen(),
      '/search' => const ReferenceSearchScreen(),
      '/search-results' => const ReferenceSearchResultsScreen(),
      '/search-empty' => const ReferenceEmptySearchScreen(),
      '/products' => const ReferenceProductListScreen(),
      '/product-list-view' => const ReferenceProductListScreen(forceList: true),
      '/offers' => const ReferenceOffersScreen(),
      '/product-filter' => const ReferenceProductFilterScreen(),
      '/coupon' => const ConnectedCouponsScreen(),
      '/product-details' => const _FirstProductScreen(),
      '/product-medicine' => const _FirstProductScreen(index: 5),
      '/product-feed' => const _FirstProductScreen(index: 2),
      '/reviews' => const _ReviewRoute(),
      '/ask-question' => const _AskRoute(),
      '/favorites' => const ReferenceFavoritesScreen(),
      '/favorites-empty' => const ReferenceFavoritesScreen(empty: true),
      '/favorites-plant-empty' => const ReferenceFavoritesScreen(plantEmpty: true),
      '/auctions' => const ReferenceAuctionListScreen(),
      '/auction-filter' => const ReferenceAuctionFilterScreen(),
      '/auction-details' => ReferenceAuctionDetailsScreen(auction: ReferenceDemoData.auctions.first),
      '/auction-gallery' => ReferenceAuctionDetailsScreen(auction: ReferenceDemoData.auctions.first, galleryMode: true),
      '/auction-bid' => ReferenceBidScreen(auction: ReferenceDemoData.auctions.first),
      '/auction-bid-confirm' => const ReferenceBidConfirmScreen(),
      '/auction-success' => const ReferenceAuctionResultScreen(kind: ReferenceAuctionResultKind.bidSuccess),
      '/auction-won' => const ReferenceAuctionResultScreen(kind: ReferenceAuctionResultKind.won),
      '/auction-ended' => const ReferenceAuctionResultScreen(kind: ReferenceAuctionResultKind.ended),
      '/my-auctions' => const ReferenceMyAuctionsScreen(),
      '/bid-history' => const ReferenceMyAuctionsScreen(history: true),
      '/auction-reminder' => const ReferenceAuctionReminderScreen(),
      '/guarantee-details' => const ReferenceGuaranteeScreen(),
      '/cart' => const ConnectedCartScreen(),
      '/cart-empty' => const ConnectedCartScreen(forceEmpty: true),
      '/checkout' => const ConnectedEnhancedCheckoutScreen(),
      '/delivery-slot' => const DeliverySlotScreen(),
      '/delivery-preferences' => const DeliveryPreferencesScreen(),
      '/payment-methods' => const PaymentMethodsScreen(),
      '/add-card' => const AddCardScreen(),
      '/edit-payment' => const PaymentMethodsScreen(),
      '/cash-on-delivery' => const CashOnDeliveryScreen(),
      '/bank-transfer' => const BankTransferScreen(),
      '/order-success' => const OrderSuccessScreen(),
      '/payment-success' => const PaymentResultScreen(success: true),
      '/payment-failed' => const PaymentResultScreen(success: false),
      '/wallet-pending' => const WalletPendingScreen(),
      '/account' => const ConnectedAccountScreen(),
      '/edit-profile' => const ConnectedEditProfileScreen(),
      '/profile-avatar' => const ConnectedAvatarScreen(),
      '/change-phone' => const ConnectedEditProfileScreen(),
      '/change-password' => const ConnectedChangePasswordScreen(),
      '/settings' => const ConnectedSettingsScreen(),
      '/notifications' => const ConnectedNotificationsScreen(),
      '/notification-preferences' => const ConnectedNotificationPreferencesScreen(),
      '/addresses' => const ConnectedAddressesScreen(),
      '/addresses-empty' => const ConnectedAddressesScreen(),
      '/add-address' => const ConnectedAddressFormScreen(),
      '/wallet' => const ConnectedResponsiveWalletScreen(),
      '/wallet-topup' => const ConnectedWalletTopUpScreen(),
      '/wallet-topup-success' => const WalletTopUpSuccessScreen(amount: 1000),
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
      '/invoice' => const _FirstInvoiceRoute(),
      '/support' => const ConnectedSupportScreen(),
      '/support-ticket' => const ConnectedSupportTicketScreen(),
      '/support-chat' => const ConnectedSupportChatScreen(),
      '/legal' => const ConnectedLegalScreen(),
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
    if (products.isEmpty) return const Scaffold(body: ResultStateView(title: 'لا توجد منتجات', message: 'لم يعرض الخادم منتجات متاحة حاليًا.', kind: ResultKind.empty));
    final safeIndex = index < 0 ? 0 : (index >= products.length ? products.length - 1 : index);
    return ReferenceProductDetailsScreen(product: products[safeIndex]);
  }
}

class _ReviewRoute extends StatelessWidget {
  const _ReviewRoute();
  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    if (products.isEmpty) return const Scaffold(body: ResultStateView(title: 'لا توجد منتجات', message: 'لا توجد بيانات تقييم متاحة.', kind: ResultKind.empty));
    return ReferenceReviewsQuestionsScreen(product: products.first);
  }
}

class _AskRoute extends StatelessWidget {
  const _AskRoute();
  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    if (products.isEmpty) return const Scaffold(body: ResultStateView(title: 'لا توجد منتجات', message: 'لا يوجد منتج متاح لعرض الأسئلة.', kind: ResultKind.empty));
    return ReferenceAskQuestionScreen(product: products.first);
  }
}

enum _OrderAction { details, track, cancel, rate, returnOrder }

class _FirstOrderActionRoute extends StatelessWidget {
  const _FirstOrderActionRoute({required this.action});
  final _OrderAction action;
  @override
  Widget build(BuildContext context) {
    final id = _firstOrderId(context);
    if (id == null) return const _NoOrderScreen();
    return switch (action) {
      _OrderAction.details => ConnectedOrderDetailsScreen(orderId: id),
      _OrderAction.track => ConnectedTrackOrderScreen(orderId: id),
      _OrderAction.cancel => ConnectedCancelOrderScreen(orderId: id),
      _OrderAction.rate => ConnectedRateOrderScreen(orderId: id),
      _OrderAction.returnOrder => ConnectedReturnRequestScreen(orderId: id),
    };
  }
}

class _FirstInvoiceRoute extends StatelessWidget {
  const _FirstInvoiceRoute();
  @override
  Widget build(BuildContext context) {
    final id = _firstOrderId(context);
    return id == null ? const _NoOrderScreen() : ConnectedInvoiceScreen(orderId: id);
  }
}

int? _firstOrderId(BuildContext context) {
  final orders = AppScope.of(context).orders;
  if (orders.isEmpty) return null;
  final id = int.tryParse(orders.first.id) ?? 0;
  return id > 0 ? id : null;
}

class _NoOrderScreen extends StatelessWidget {
  const _NoOrderScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(body: ResultStateView(title: 'لا توجد طلبات', message: 'لا يوجد طلب متاح لهذه العملية.', kind: ResultKind.empty));
}
