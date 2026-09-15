import 'package:flutter/material.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/marketplace/data/marketplace_repository.dart';
import '../../features/marketplace/domain/marketplace_models.dart';
import '../network/api_client.dart';

class AppController extends ChangeNotifier {
  AppController({ApiClient? apiClient}) : client = apiClient ?? ApiClient() {
    repository = MarketplaceRepository(client);
    authRepository = AuthRepository(client);
  }

  final ApiClient client;
  late final MarketplaceRepository repository;
  late final AuthRepository authRepository;

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

  List<Product> get products => List.unmodifiable(_products);
  List<Auction> get auctions => List.unmodifiable(_auctions);
  List<String> get categories => List.unmodifiable(_categories);
  List<CartLine> get cart => List.unmodifiable(_cart);
  List<AppOrder> get orders => repository.orders;
  bool get isAuthenticated => session != null && client.accessToken != null;

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
    } on Object catch (error) {
      errorMessage = _message(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts({String? query, String sort = 'best_selling'}) async {
    try {
      final data = await repository.fetchProducts(query: query, sort: sort);
      _products
        ..clear()
        ..addAll(data);
      errorMessage = null;
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
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
        ..addAll(data);
      errorMessage = null;
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
      rethrow;
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
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshOrders() async {
    if (!isAuthenticated) return;
    try {
      await repository.fetchOrders(_products);
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    errorMessage = null;
    try {
      session = await authRepository.login(email: email, password: password);
      await Future.wait<void>([
        refreshCart(),
        refreshWishlist(),
        refreshOrders(),
      ]);
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
      await Future.wait<void>([
        refreshCart(),
        refreshWishlist(),
        refreshOrders(),
      ]);
      notifyListeners();
    } on Object catch (error) {
      errorMessage = _message(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
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
        if (wishlistId != null) {
          await repository.removeWishlist(wishlistId);
        }
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
    if (itemId == null) return;
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
