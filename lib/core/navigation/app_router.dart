import 'package:flutter/material.dart';

import '../../features/account/presentation/account_screens.dart';
import '../../features/account/presentation/connected_account_data_screens.dart';
import '../../features/account/presentation/connected_account_screen.dart';
import '../../features/account/presentation/connected_customer_service_screens.dart';
import '../../features/account/presentation/connected_delete_account_screen.dart';
import '../../features/account/presentation/connected_responsive_wallet_screen.dart';
import '../../features/account/presentation/connected_server_account_extras.dart';
import '../../features/account/presentation/matched_account_extras.dart';
import '../../features/account/presentation/matched_account_screen.dart';
import '../../features/account/presentation/matched_order_return_screens.dart';
import '../../features/account/presentation/pixel_orders_screen.dart';
import '../../features/auctions/presentation/pixel_auction_screens.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/connected_auth_screens.dart';
import '../../features/auth/presentation/connected_phone_verification_screen.dart';
import '../../features/auth/presentation/connected_recovery_screens.dart';
import '../../features/auth/presentation/matched_auth_location_screens.dart';
import '../../features/auth/presentation/matched_onboarding_screen.dart';
import '../../features/cart/presentation/cart_screens.dart';
import '../../features/cart/presentation/connected_cart_screens.dart';
import '../../features/cart/presentation/connected_coupons_screen.dart';
import '../../features/cart/presentation/fixed_checkout_screen.dart';
import '../../features/cart/presentation/matched_cart_screens.dart';
import '../../features/cart/presentation/matched_delivery_payment_screens.dart';
import '../../features/cart/presentation/pixel_checkout_result_screens.dart';
import '../../features/marketplace/presentation/matched_marketplace_screens.dart';
import '../../features/marketplace/presentation/matched_product_screens.dart';
import '../../features/marketplace/presentation/pixel_medicine_screen.dart';
import '../../features/marketplace/presentation/reference_marketplace_screens.dart';
import '../../features/marketplace/presentation/reference_nav_wrappers.dart';
import '../../features/marketplace/presentation/reference_product_screens.dart';
import '../../features/shell/main_shell.dart';
import '../../shared/widgets/mazraa_widgets.dart';
import '../state/app_controller.dart';

const bool _referenceVisual = bool.fromEnvironment('REFERENCE_VISUAL_TEST');

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      '/' => const MainShell(),
      '/onboarding' => const MatchedOnboardingScreen(),
      '/login' => const ConnectedLoginScreen(),
      '/register' => const ConnectedRegisterScreen(),
      '/forgot-password' => const ConnectedForgotPasswordScreen(),
      '/reset-password' => const ConnectedResetPasswordScreen(),
      '/otp' => const MatchedPhoneVerificationScreen(),
      '/location-permission' => const MatchedLocationPermissionScreen(),
      '/location' => const MatchedLocationPickerScreen(),
      '/categories' => const FinalCategoriesScreen(),
      '/search' => const FinalSearchScreen(),
      '/search-results' => const ReferenceSearchResultsScreen(),
      '/search-empty' => const MatchedEmptySearchScreen(),
      '/products' => const ReferenceProductListScreen(),
      '/product-list-view' => const ReferenceProductListScreen(forceList: true),
      '/offers' => const ReferenceOffersScreen(),
      '/product-filter' => const MatchedProductFilterScreen(),
      '/coupon' => const ConnectedCouponsScreen(),
      '/product-details' => const MatchedFirstProductScreen(),
      '/product-medicine' => const PixelMedicineProductScreen(),
      '/product-feed' => const MatchedFeedProductScreen(),
      '/reviews' => const _ReviewRoute(),
      '/ask-question' => const _AskRoute(),
      '/favorites' => const FinalFavoritesScreen(),
      '/favorites-empty' => const FinalFavoritesScreen(empty: true),
      '/favorites-plant-empty' => const FinalFavoritesScreen(plantEmpty: true),
      '/auctions' => const PixelAuctionListScreen(),
      '/auction-filter' => const PixelAuctionFilterScreen(),
      '/auction-details' => const PixelAuctionDetailsScreen(),
      '/auction-gallery' => const PixelAuctionDetailsScreen(galleryMode: true),
      '/auction-bid' => const PixelBidScreen(),
      '/auction-bid-confirm' => const PixelBidConfirmScreen(),
      '/auction-success' => const PixelAuctionResultScreen(kind: PixelAuctionResultKind.success),
      '/auction-won' => const PixelAuctionResultScreen(kind: PixelAuctionResultKind.won),
      '/auction-ended' => const PixelAuctionResultScreen(kind: PixelAuctionResultKind.ended),
      '/my-auctions' => const PixelMyAuctionsScreen(),
      '/bid-history' => const PixelMyAuctionsScreen(history: true),
      '/auction-reminder' => const PixelReminderScreen(),
      '/guarantee-details' => const PixelGuaranteeScreen(),
      '/cart' => const MatchedCartScreen(),
      '/cart-empty' => const MatchedCartScreen(forceEmpty: true),
      '/checkout' => const FixedCheckoutScreen(),
      '/delivery-slot' => const MatchedDeliverySlotScreen(),
      '/delivery-preferences' => const MatchedDeliveryPreferencesScreen(),
      '/payment-methods' => const MatchedPaymentMethodsScreen(),
      '/add-card' => const MatchedCardFormScreen(),
      '/edit-payment' => const MatchedCardFormScreen(editing: true),
      '/cash-on-delivery' => const MatchedCashOnDeliveryScreen(),
      '/bank-transfer' => const MatchedBankTransferScreen(),
      '/order-success' => const PixelOrderSuccessScreen(),
      '/payment-success' => const PixelPaymentResultScreen(success: true),
      '/payment-failed' => const PixelPaymentResultScreen(success: false),
      '/wallet-pending' => const PixelWalletPendingScreen(),
      '/account' => const MatchedAccountScreen(),
      '/edit-profile' => const MatchedEditProfileScreen(),
      '/profile-avatar' => const ConnectedAvatarScreen(),
      '/change-phone' => const MatchedChangePhoneScreen(),
      '/change-password' => const MatchedChangePasswordScreen(),
      '/settings' => const ConnectedSettingsScreen(),
      '/notifications' => const ConnectedNotificationsScreen(),
      '/notification-preferences' => const MatchedNotificationPreferencesScreen(),
      '/addresses' => const ConnectedAddressesScreen(),
      '/addresses-empty' => const MatchedEmptyAddressesScreen(),
      '/add-address' => const MatchedAddAddressScreen(),
      '/wallet' => const ConnectedResponsiveWalletScreen(),
      '/wallet-topup' => const ConnectedWalletTopUpScreen(),
      '/wallet-topup-success' => const WalletTopUpSuccessScreen(amount: 1000),
      '/wallet-transactions' => const ConnectedWalletTransactionsScreen(),
      '/orders' => const PixelAwareOrdersScreen(),
      '/order-details' => const _FirstOrderActionRoute(action: _OrderAction.details),
      '/track-order' => const _FirstOrderActionRoute(action: _OrderAction.track),
      '/cancel-order' => const _FirstOrderActionRoute(action: _OrderAction.cancel),
      '/order-cancelled' => const MatchedOrderCancelledScreen(),
      '/rate-order' => const _FirstOrderActionRoute(action: _OrderAction.rate),
      '/returns' => const MatchedReturnsScreen(),
      '/return-request' => const _FirstOrderActionRoute(action: _OrderAction.returnOrder),
      '/return-success' => const MatchedReturnSuccessScreen(),
      '/refund-status' => const MatchedRefundStatusScreen(),
      '/invoice' => const _FirstInvoiceRoute(),
      '/support' => const ConnectedSupportScreen(),
      '/support-ticket' => const ConnectedSupportTicketScreen(),
      '/support-chat' => const MatchedSupportChatScreen(),
      '/legal' => const MatchedLegalScreen(),
      '/delete-account' => const ConnectedDeleteAccountScreen(),
      '/offline' => const MatchedOfflineScreen(),
      _ => const MainShell(),
    };
    return MaterialPageRoute(settings: settings, builder: (_) => page);
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
    return ReferenceReviewsQuestionsScreen(product: products.first);
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
    if (id == null) {
      return switch (action) {
        _OrderAction.details => const MatchedOrderDetailsScreen(),
        _OrderAction.track => const MatchedTrackOrderScreen(),
        _OrderAction.cancel => const MatchedCancelOrderScreen(),
        _OrderAction.rate => const MatchedRateOrderScreen(),
        _OrderAction.returnOrder => const MatchedReturnRequestScreen(),
      };
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

class _FirstInvoiceRoute extends StatelessWidget {
  const _FirstInvoiceRoute();

  @override
  Widget build(BuildContext context) {
    final id = _firstOrderId(context);
    return id == null
        ? const MatchedInvoiceScreen()
        : ConnectedInvoiceScreen(orderId: id);
  }
}

int? _firstOrderId(BuildContext context) {
  if (_referenceVisual) return null;
  final orders = AppScope.of(context).orders;
  if (orders.isEmpty) return null;
  final id = int.tryParse(orders.first.id) ?? 0;
  return id > 0 ? id : null;
}
