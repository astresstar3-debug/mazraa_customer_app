import '../state/app_controller.dart';
import 'reference_demo_data.dart';
import '../../features/marketplace/domain/marketplace_models.dart';

/// Deterministic data controller used only by screenshot/reference CI.
/// Authentication still uses the real test server, but visual collections are
/// frozen so server seed changes cannot alter the screenshots being compared.
class ReferenceVisualAppController extends AppController {
  ReferenceVisualAppController() {
    favorites.addAll(ReferenceDemoData.products.take(2).map((item) => item.id));
    location = 'الرياض';
  }

  @override
  List<Product> get products => List.unmodifiable(ReferenceDemoData.products);

  @override
  List<Auction> get auctions => List.unmodifiable(ReferenceDemoData.auctions);

  @override
  List<String> get categories => List.unmodifiable(ReferenceDemoData.categories);

  @override
  List<CartLine> get cart => isAuthenticated
      ? List.unmodifiable(ReferenceDemoData.cart)
      : const <CartLine>[];

  @override
  List<AppOrder> get orders => List.unmodifiable(ReferenceDemoData.orders);

  @override
  int get cartCount => cart.fold(0, (sum, line) => sum + line.quantity);

  @override
  double get subtotal => cart.fold(
        0,
        (sum, line) => sum + line.product.price * line.quantity,
      );

  @override
  bool isFavorite(String id) =>
      ReferenceDemoData.products.take(2).any((product) => product.id == id);

  @override
  Future<void> refreshProducts({String? query, String sort = 'best_selling'}) async {
    notifyListeners();
  }

  @override
  Future<void> refreshCart() async {
    notifyListeners();
  }

  @override
  Future<void> refreshWishlist() async {
    favorites
      ..clear()
      ..addAll(ReferenceDemoData.products.take(2).map((item) => item.id));
    notifyListeners();
  }

  @override
  Future<void> refreshOrders() async {
    notifyListeners();
  }
}
