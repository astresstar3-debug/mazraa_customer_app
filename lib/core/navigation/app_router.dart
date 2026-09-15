import 'package:flutter/material.dart';

import '../../features/account/presentation/account_screens.dart';
import '../../features/account/presentation/connected_account_screen.dart';
import '../../features/account/presentation/misc_screens.dart';
import '../../features/auctions/presentation/auction_screens.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/connected_auth_screens.dart';
import '../../features/cart/presentation/cart_screens.dart';
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
      '/forgot-password' => const ForgotPasswordScreen(),
      '/otp' => const OtpScreen(),
      '/location-permission' => const LocationPermissionScreen(),
      '/location' => const LocationScreen(),
      '/categories' => const CategoriesScreen(),
      '/search' => const SearchScreen(),
      '/products' => const ProductListScreen(),
      '/offers' => const OffersScreen(),
      '/coupon' => const CouponScreen(),
      '/product-details' => const _FirstProductScreen(),
      '/product-medicine' => const _FirstProductScreen(index: 7),
      '/product-feed' => const _FirstProductScreen(index: 3),
      '/reviews' => const _ReviewRoute(),
      '/ask-question' => const _AskRoute(),
      '/favorites' => const FavoritesScreen(),
      '/favorites-empty' => const FavoritesScreen(empty: true),
      '/auctions' => const AuctionListScreen(),
      '/auction-details' => const _FirstAuctionScreen(),
      '/auction-gallery' => const _FirstAuctionScreen(index: 2),
      '/auction-bid' => const _BidRoute(),
      '/auction-success' => const _AuctionResultRoute(),
      '/auction-won' => const _AuctionResultRoute(kind: AuctionResultKind.won),
      '/auction-ended' => const _AuctionResultRoute(
        kind: AuctionResultKind.ended,
      ),
      '/my-auctions' => const MyAuctionsScreen(),
      '/bid-history' => const MyAuctionsScreen(history: true),
      '/auction-reminder' => const _ReminderRoute(),
      '/guarantee-details' => const GuaranteeDetailsScreen(),
      '/cart' => const CartScreen(),
      '/cart-empty' => const CartScreen(forceEmpty: true),
      '/checkout' => const CheckoutScreen(),
      '/delivery-slot' => const DeliverySlotScreen(),
      '/delivery-preferences' => const DeliveryPreferencesScreen(),
      '/payment-methods' => const PaymentMethodsScreen(),
      '/add-card' => const AddCardScreen(),
      '/edit-payment' => const PaymentMethodsScreen(),
      '/cash-on-delivery' => const CashOnDeliveryScreen(),
      '/bank-transfer' => const BankTransferScreen(),
      '/order-success' => const OrderSuccessScreen(),
      '/payment-success' => const PaymentResultScreen(),
      '/payment-failed' => const PaymentResultScreen(success: false),
      '/wallet-pending' => const WalletPendingScreen(),
      '/account' => const ConnectedAccountScreen(),
      '/edit-profile' => const SimpleFormScreen(
        title: 'تعديل البيانات',
        icon: Icons.person_rounded,
        fields: [
          FormFieldSpec('الاسم الكامل', Icons.person_outline_rounded),
          FormFieldSpec('رقم الجوال', Icons.phone_outlined, phone: true),
          FormFieldSpec('البريد الإلكتروني', Icons.email_outlined),
          FormFieldSpec('المدينة', Icons.location_on_outlined),
        ],
      ),
      '/change-phone' => const SimpleFormScreen(
        title: 'تغيير رقم الهاتف',
        icon: Icons.phonelink_lock_rounded,
        button: 'إرسال رمز التحقق',
        fields: [
          FormFieldSpec(
            'رقم الجوال الحالي',
            Icons.phone_android_rounded,
            phone: true,
          ),
          FormFieldSpec('رقم الجوال الجديد', Icons.phone_outlined, phone: true),
        ],
      ),
      '/change-password' => const SimpleFormScreen(
        title: 'تغيير كلمة المرور',
        icon: Icons.lock_rounded,
        button: 'تحديث كلمة المرور',
        fields: [
          FormFieldSpec(
            'كلمة المرور الحالية',
            Icons.lock_outline_rounded,
            secure: true,
          ),
          FormFieldSpec(
            'كلمة المرور الجديدة',
            Icons.lock_reset_rounded,
            secure: true,
          ),
          FormFieldSpec(
            'تأكيد كلمة المرور',
            Icons.verified_user_outlined,
            secure: true,
          ),
        ],
      ),
      '/settings' => const SettingsScreen(),
      '/notifications' => const NotificationsScreen(),
      '/notification-preferences' => const NotificationPreferencesScreen(),
      '/addresses' => const AddressesScreen(),
      '/addresses-empty' => const AddressesScreen(empty: true),
      '/add-address' => const SimpleFormScreen(
        title: 'إضافة عنوان جديد',
        icon: Icons.add_location_alt_rounded,
        button: 'حفظ العنوان',
        fields: [
          FormFieldSpec('الاسم', Icons.person_outline_rounded),
          FormFieldSpec('رقم الهاتف', Icons.phone_outlined, phone: true),
          FormFieldSpec('المدينة', Icons.location_city_outlined),
          FormFieldSpec('المنطقة', Icons.map_outlined),
          FormFieldSpec('تفاصيل العنوان', Icons.home_outlined, multiline: true),
        ],
      ),
      '/wallet' => const WalletScreen(),
      '/wallet-topup' => const WalletTopUpScreen(),
      '/wallet-topup-success' => const WalletTopUpSuccessScreen(amount: 1000),
      '/wallet-transactions' => const WalletTransactionsScreen(),
      '/orders' => const OrdersScreen(),
      '/order-details' => const OrderDetailsScreen(),
      '/track-order' => const TrackOrderScreen(),
      '/cancel-order' => const CancelOrderScreen(),
      '/order-cancelled' => const GenericActionResultScreen(
        title: 'تم إلغاء الطلب بنجاح',
        message:
            'تم إلغاء طلبك وسيتم استرداد المبلغ إلى محفظتك خلال الفترة المحددة.',
      ),
      '/rate-order' => const RateOrderScreen(),
      '/returns' => const ReturnsScreen(),
      '/return-request' => const ReturnRequestScreen(),
      '/return-success' => const GenericActionResultScreen(
        title: 'تم إرسال طلب الإرجاع',
        message: 'تم إرسال الطلب بنجاح وسنخبرك بالتحديثات.',
      ),
      '/refund-status' => const RefundStatusScreen(),
      '/invoice' => const InvoiceScreen(),
      '/support' => const SupportScreen(),
      '/support-ticket' => const SimpleFormScreen(
        title: 'فتح تذكرة دعم',
        icon: Icons.confirmation_number_outlined,
        button: 'إرسال التذكرة',
        fields: [
          FormFieldSpec('نوع المشكلة', Icons.category_outlined),
          FormFieldSpec('رقم الطلب (اختياري)', Icons.receipt_outlined),
          FormFieldSpec('عنوان المشكلة', Icons.edit_outlined),
          FormFieldSpec(
            'اشرح المشكلة بالتفصيل',
            Icons.chat_bubble_outline_rounded,
            multiline: true,
          ),
        ],
      ),
      '/support-chat' => const SupportChatScreen(),
      '/legal' => const LegalScreen(),
      '/delete-account' => const DeleteAccountScreen(),
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
    final safeIndex = index < 0
        ? 0
        : (index >= products.length ? products.length - 1 : index);
    return ProductDetailsScreen(product: products[safeIndex]);
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
    return ReviewsScreen(product: products.first);
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
          message: 'لا يوجد منتج متاح لطرح سؤال عنه.',
          kind: ResultKind.empty,
        ),
      );
    }
    return AskQuestionScreen(product: products.first);
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
    final safeIndex = index < 0
        ? 0
        : (index >= auctions.length ? auctions.length - 1 : index);
    return AuctionDetailsScreen(auction: auctions[safeIndex]);
  }
}

class _BidRoute extends StatelessWidget {
  const _BidRoute();
  @override
  Widget build(BuildContext context) {
    final auctions = AppScope.of(context).auctions;
    if (auctions.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد مزادات',
          message: 'لا يوجد مزاد متاح للمزايدة الآن.',
          kind: ResultKind.empty,
        ),
      );
    }
    return BidScreen(auction: auctions.first);
  }
}

class _AuctionResultRoute extends StatelessWidget {
  const _AuctionResultRoute({this.kind = AuctionResultKind.success});
  final AuctionResultKind kind;
  @override
  Widget build(BuildContext context) {
    final auctions = AppScope.of(context).auctions;
    if (auctions.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد مزادات',
          message: 'لا توجد بيانات مزاد متاحة.',
          kind: ResultKind.empty,
        ),
      );
    }
    return AuctionResultScreen(auction: auctions.first, kind: kind);
  }
}

class _ReminderRoute extends StatelessWidget {
  const _ReminderRoute();
  @override
  Widget build(BuildContext context) {
    final auctions = AppScope.of(context).auctions;
    if (auctions.isEmpty) {
      return const Scaffold(
        body: ResultStateView(
          title: 'لا توجد مزادات',
          message: 'لا يوجد مزاد متاح لإضافة تذكير.',
          kind: ResultKind.empty,
        ),
      );
    }
    return AuctionReminderScreen(auction: auctions.first);
  }
}
