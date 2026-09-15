enum ProductKind { crop, animal, supply, medicine, feed }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.oldPrice,
    this.rating = 4.8,
    this.reviews = 86,
    this.discount,
    this.kind = ProductKind.crop,
    this.description =
        'منتج مختار بعناية من مزارع موثوقة، بجودة عالية وتجهيز مناسب للتوصيل.',
  });
  final String id;
  final String name;
  final String image;
  final double price;
  final double? oldPrice;
  final String category;
  final double rating;
  final int reviews;
  final int? discount;
  final ProductKind kind;
  final String description;
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
    this.bidCount = 24,
    this.state = AuctionState.live,
  });
  final String id;
  final String title;
  final String image;
  final double currentBid;
  final Duration remaining;
  final String category;
  final int bidCount;
  final AuctionState state;
}

class CartLine {
  const CartLine(this.product, this.quantity);
  final Product product;
  final int quantity;
  CartLine copyWith({int? quantity}) =>
      CartLine(product, quantity ?? this.quantity);
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
