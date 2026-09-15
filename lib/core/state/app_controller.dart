import 'package:flutter/material.dart';

import '../../features/marketplace/data/marketplace_repository.dart';
import '../../features/marketplace/domain/marketplace_models.dart';

class AppController extends ChangeNotifier {
  AppController({MarketplaceRepository? repository})
    : repository = repository ?? const LocalMarketplaceRepository();
  final MarketplaceRepository repository;
  final Set<String> favorites = {'honey', 'seedlings'};
  final Map<String, int> _cart = {'honey': 1, 'dates': 2};
  ThemeMode themeMode = ThemeMode.light;
  String location = 'الرياض';

  List<Product> get products => repository.products;
  List<Auction> get auctions => repository.auctions;
  List<CartLine> get cart => _cart.entries
      .map((e) => CartLine(products.firstWhere((p) => p.id == e.key), e.value))
      .toList();
  int get cartCount => _cart.values.fold(0, (sum, value) => sum + value);
  double get subtotal =>
      cart.fold(0, (sum, line) => sum + line.product.price * line.quantity);
  bool isFavorite(String id) => favorites.contains(id);
  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    notifyListeners();
  }

  void addToCart(Product product) {
    _cart.update(product.id, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void setQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = quantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void toggleTheme(bool dark) {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocation(String value) {
    location = value;
    notifyListeners();
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
