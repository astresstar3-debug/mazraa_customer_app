enum ProductKind { crop, animal, supply, medicine, feed }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.variantId,
    this.oldPrice,
    this.rating = 0,
    this.reviews = 0,
    this.discount,
    this.kind = ProductKind.crop,
    this.description = '',
    this.inStock = true,
    this.sales = 0,
    this.images = const [],
  });

  final String id;
  final int? variantId;
  final String name;
  final String image;
  final List<String> images;
  final double price;
  final double? oldPrice;
  final String category;
  final double rating;
  final int reviews;
  final int? discount;
  final ProductKind kind;
  final String description;
  final bool inStock;
  final int sales;
}

enum AuctionState { live, upcoming, ended, won }

class Auction {
  const Auction({
    required this.id,
    required this.title,
    required this.image,
    required this.currentBid,
    required this.remaining,
    required this.category,
    this.bidCount = 0,
    this.state = AuctionState.live,
    this.description = '',
  });

  final String id;
  final String title;
  final String image;
  final double currentBid;
  final Duration remaining;
  final String category;
  final int bidCount;
  final AuctionState state;
  final String description;
}

class CartLine {
  const CartLine(this.product, this.quantity, {this.cartItemId});
  final Product product;
  final int quantity;
  final int? cartItemId;

  CartLine copyWith({int? quantity, int? cartItemId}) => CartLine(
        product,
        quantity ?? this.quantity,
        cartItemId: cartItemId ?? this.cartItemId,
      );
}

class AppOrder {
  const AppOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.products,
    required this.date,
  });
  final String id;
  final String status;
  final double total;
  final List<Product> products;
  final DateTime date;
}
