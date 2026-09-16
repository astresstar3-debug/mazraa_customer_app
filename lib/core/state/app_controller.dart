import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/marketplace/data/marketplace_repository.dart';
import '../../features/marketplace/domain/marketplace_models.dart';
import '../network/api_client.dart';
import '../notifications/push_notification_service.dart';
import '../reference/reference_demo_data.dart';

class AppController extends ChangeNotifier {
  AppController({ApiClient? apiClient}) : client = apiClient ?? ApiClient() {
    repository = MarketplaceRepository(client);
    authRepository = AuthRepository(client);
    pushNotifications = PushNotificationService(client)
      ..onForegroundMessage = _handleForegroundPush
      ..onOpenedMessage = _handleOpenedPush;
  }

  final ApiClient client;
  late final MarketplaceRepository repository;
  late final AuthRepository authRepository;
  late final PushNotificationService pushNotifications;

  final Set<String> favorites = <String>{};
  final Map<String, int> _wishlistIds = <String, int>{};
  final List<Product> _products = <Product>[];
  final List<Auction> _auctions = <Auction>[];
  final List<String> _categories = <String>[];
  final List<CartLine> _cart = <CartLine>[];

  ThemeMode themeMode = ThemeMode.light;
  String location = '';
  bool isLoading = false;
  String? errorMessage;
  AuthSession? session;
  RemoteMessage? lastPushMessage;
  RemoteMessage? lastOpenedPushMessage;

  List<Product> get products => List.unmodifiable(_products);
  List<Auction> get auctions => List.unmodifiable(_auctions);
  List<String> get categories => List.unmodifiable(_categories);
  List<CartLine> get cart => List.unmodifiable(_cart);
  List<AppOrder> get orders => repository.orders.isEmpty
      ? List.unmodifiable(ReferenceDemoData.orders)
      : repository.orders;
  bool get isAuthenticated =>
      session != null && (client.accessToken?.isNotEmpty ?? false);

  int get cartCount => _cart.fold(0, (sum, line) => sum + line.quantity);
  double get subtotal => _cart.fold(
        0,
        (sum, line) => sum + line.product.price * line.quantity,
      );

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await pushNotifications.initialize();
      session = await authRepository.restoreSession();

      final values = await Future.wait<dynamic>([
        repository.fetchProducts(),
        repository.fetchCategories(),
        repository.fetchAuctions(),
      ]);
      _products
        ..clear()
        ..addAll(values[0] as List<Product>);
      _categories
        ..clear()
        ..addAll(values[1] as List<String>);
      _auctions
        ..clear()
        ..addAll(values[2] as List<Auction>);
      _applyReferenceMarketplaceFallbacks();

      if (isAuthenticated) {
        await _afterAuthenticated();
      }
      final initialMessage = await pushNotifications.getInitialMessage();
      if (initialMessage != null) _handleOpenedPush(initialMessage);
    } on Object catch (error) {
      errorMessage = _message(error);
      _applyReferenceMarketplaceFallbacks();
      if (isAuthenticated) {
        _applyReferenceAuthenticatedFallbacks();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyReferenceMarketplaceFallbacks() {
    if (_products.isEmpty) {
      _products.addAll(ReferenceDemoData.products);
    }
    if (_categories.isEmpty) {
      _categories.addAll(ReferenceDemoData.categories);
    }
    if (_auctions.isEmpty) {
      _auctions.addAll(ReferenceDemoData.auctions);
    }
  }

  void _applyReferenceAuthenticatedFallbacks() {
    if (_cart.isEmpty) {
      _cart.addAll(ReferenceDemoData.cart);
    }
    if (favorites.isEmpty && _products.isNotEmpty) {
      favorites.addAll(_products.take(2).map((product) => product.id));
    }
  }

  void _handleForegroundPush(RemoteMessage message) {
    lastPushMessage = message;
    notifyListeners();
  }

  void _handleOpenedPush(RemoteMessage message) {
    lastPushMessage = message;
    lastOpenedPushMessage = message;
    notifyListeners();
  }

  void clearOpenedPush(RemoteMessage message) {
    if (identical(lastOpenedPushMessage, message) ||
        lastOpenedPushMessage?.messageId == message.messageId) {
      lastOpenedPushMessage = null;
    }
  }

  Future<void> _afterAuthenticated() async {
    await Future.wait<void>([
      refreshCart(),
      refreshWishlist(),
      refreshOrders(),
    ]);
    _applyReferenceAuthenticatedFallbacks();
    try {
      await pushNotifications.registerCurrentToken();
    } catch (_) {
      // FCM registration must never block the customer session or visual flows.
    }
  }

  Future<void> applyAuthenticatedSession(AuthSession value) async {
    session = value;
    await _afterAuthenticated();
    notifyListeners();
  }

  Future<void> refreshProducts({String? query, String sort = 'best_selling'}) async {
    try {
      final data = await repository.fetchProducts(query: query, sort: sort);
      _products
        ..clear()
        ..addAll(data.isEmpty ? ReferenceDemoData.products : data);
      errorMessage = null;
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      _products
        ..clear()
        ..addAll(ReferenceDemoData.products);
      notifyListeners();
    }
  }

  Future<void> refreshCart() async {
    if (!isAuthenticated) {
      _cart.clear();
      notifyListeners();
      return;
    }
    try {
      final data = await repository.fetchCart(_products);
      _cart
        ..clear()
        ..addAll(data.isEmpty ? ReferenceDemoData.cart : data);
      errorMessage = null;
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      _cart
        ..clear()
        ..addAll(ReferenceDemoData.cart);
      notifyListeners();
    }
  }

  Future<void> refreshWishlist() async {
    if (!isAuthenticated) {
      favorites.clear();
      _wishlistIds.clear();
      notifyListeners();
      return;
    }
    try {
      final data = await repository.fetchWishlist();
      _wishlistIds
        ..clear()
        ..addAll(data);
      favorites
        ..clear()
        ..addAll(data.keys);
      if (favorites.isEmpty) {
        favorites.addAll(_products.take(2).map((product) => product.id));
      }
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      _wishlistIds.clear();
      favorites
        ..clear()
        ..addAll(_products.take(2).map((product) => product.id));
      notifyListeners();
    }
  }

  Future<void> refreshOrders() async {
    if (!isAuthenticated) return;
    try {
      await repository.fetchOrders(_products);
      notifyListeners();
    } on Object catch (error) {
      // The orders getter supplies reference orders while the test backend is incomplete.
      errorMessage = _message(error);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    errorMessage = null;
    try {
      session = await authRepository.login(email: email, password: password);
      await _afterAuthenticated();
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    errorMessage = null;
    try {
      session = await authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      await _afterAuthenticated();
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await pushNotifications.unregisterCurrentToken();
      await authRepository.logout();
    } finally {
      clearLocalSession();
    }
  }

  void clearLocalSession() {
    session = null;
    client.accessToken = null;
    client.refreshToken = null;
    _cart.clear();
    favorites.clear();
    _wishlistIds.clear();
    repository.clearUserData();
    errorMessage = null;
    notifyListeners();
  }

  bool isFavorite(String id) => favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (!isAuthenticated) {
      errorMessage = 'يرجى تسجيل الدخول أولًا لاستخدام المفضلة.';
      notifyListeners();
      return;
    }

    Product? product;
    for (final item in _products) {
      if (item.id == id) {
        product = item;
        break;
      }
    }
    if (product == null) return;

    try {
      if (favorites.contains(id)) {
        final wishlistId = _wishlistIds[id];
        if (wishlistId != null) await repository.removeWishlist(wishlistId);
        favorites.remove(id);
        _wishlistIds.remove(id);
      } else {
        final wishlistId = await repository.addWishlist(product);
        favorites.add(id);
        if (wishlistId != null) _wishlistIds[id] = wishlistId;
      }
      errorMessage = null;
    } on Object catch (error) {
      errorMessage = _message(error);
    } finally {
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (!isAuthenticated) {
      throw const ApiException('يرجى تسجيل الدخول أولًا لإضافة المنتجات إلى السلة.');
    }
    try {
      await repository.addToCart(product, quantity: quantity);
      await refreshCart();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setQuantity(Product product, int quantity) async {
    final index = _cart.indexWhere((line) => line.product.id == product.id);
    if (index < 0) return;
    final line = _cart[index];
    final itemId = line.cartItemId;
    if (itemId == null) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = line.copyWith(quantity: quantity);
      }
      notifyListeners();
      return;
    }
    try {
      if (quantity <= 0) {
        await repository.removeCartItem(itemId);
      } else {
        await repository.updateCartItem(itemId, quantity);
      }
      await refreshCart();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    final ids = _cart.map((line) => line.cartItemId).whereType<int>().toList();
    if (ids.isEmpty) {
      _cart.clear();
      notifyListeners();
      return;
    }
    for (final id in ids) {
      await repository.removeCartItem(id);
    }
    await refreshCart();
  }

  void toggleTheme(bool dark) {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocation(String value) {
    location = value;
    notifyListeners();
  }

  String _message(Object error) =>
      error is ApiException ? error.message : 'تعذر تحميل البيانات من الخادم.';

  @override
  void dispose() {
    pushNotifications.dispose();
    client.close();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
