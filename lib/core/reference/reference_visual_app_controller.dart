import '../../features/auth/data/auth_repository.dart';
import '../../features/marketplace/domain/marketplace_models.dart';
import '../state/app_controller.dart';
import 'reference_demo_data.dart';

/// Deterministic controller used only by screenshot/reference CI.
/// Visual collections and authentication are frozen so backend/network changes
/// cannot prevent the complete reference-screen suite from being captured.
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
  Future<void> login(String email, String password) async {
    const visualSession = AuthSession(
      accessToken: 'reference-visual-access-token',
      refreshToken: 'reference-visual-refresh-token',
      userId: 1,
      email: 'b@b.com',
      roles: <String>['Customer'],
    );
    client.accessToken = visualSession.accessToken;
    client.refreshToken = visualSession.refreshToken;
    session = visualSession;
    errorMessage = null;
    favorites
      ..clear()
      ..addAll(ReferenceDemoData.products.take(2).map((item) => item.id));
    notifyListeners();
  }

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
