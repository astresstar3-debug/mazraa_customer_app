import '../../features/marketplace/domain/marketplace_models.dart';

/// Temporary, isolated visual fallback data.
///
/// Real API data always wins. These values are only used when the test/development
/// backend returns an empty collection so the customer UI can remain complete while
/// backend endpoints and seed data are still being finalized.
abstract final class ReferenceDemoData {
  static const categories = <String>[
    'الزراعة',
    'حيوانات',
    'الأعلاف والحبوب',
    'الأدوية البيطرية',
    'معدات زراعية',
    'مستلزمات النحل',
  ];

  static const products = <Product>[
    Product(
      id: 'reference-product-honey',
      name: 'عسل سدر طبيعي فاخر',
      image: 'assets/images/home/sidr_honey.png',
      images: ['assets/images/home/sidr_honey.png'],
      price: 145,
      oldPrice: 185,
      category: 'منتجات النحل',
      rating: 4.8,
      reviews: 56,
      discount: 22,
      sales: 184,
      description: 'عسل سدر طبيعي مختار بعناية من مناحل موثوقة.',
    ),
    Product(
      id: 'reference-product-seedlings',
      name: 'شتلات نخيل ممتازة',
      image: 'assets/images/home/date_seedlings.png',
      images: ['assets/images/home/date_seedlings.png'],
      price: 120,
      oldPrice: 150,
      category: 'الزراعة',
      rating: 4.7,
      reviews: 34,
      discount: 20,
      sales: 92,
      description: 'شتلات نخيل جاهزة للزراعة ومناسبة للمزارع المنزلية والتجارية.',
    ),
    Product(
      id: 'reference-product-feed',
      name: 'علف مواشي عالي الجودة',
      image: 'assets/images/home/livestock_feed.png',
      images: ['assets/images/home/livestock_feed.png'],
      price: 185,
      category: 'الأعلاف والحبوب',
      kind: ProductKind.feed,
      rating: 4.6,
      reviews: 41,
      sales: 137,
      description: 'خلطة أعلاف متوازنة مخصصة للمواشي.',
    ),
    Product(
      id: 'reference-product-dates',
      name: 'تمر فاخر',
      image: 'assets/images/home/dates.png',
      images: ['assets/images/home/dates.png'],
      price: 85,
      oldPrice: 100,
      category: 'منتجات زراعية',
      rating: 4.9,
      reviews: 73,
      discount: 15,
      sales: 261,
      description: 'تمر مختار بجودة عالية وتعبئة مناسبة.',
    ),
    Product(
      id: 'reference-product-herbs',
      name: 'أعشاب طازجة',
      image: 'assets/images/home/fresh_herbs.png',
      images: ['assets/images/home/fresh_herbs.png'],
      price: 45,
      category: 'الزراعة',
      rating: 4.5,
      reviews: 29,
      sales: 109,
      description: 'أعشاب زراعية طازجة من مزارع محلية.',
    ),
    Product(
      id: 'reference-product-calf',
      name: 'عجل محلي',
      image: 'assets/images/home/local_calf.png',
      images: ['assets/images/home/local_calf.png'],
      price: 5500,
      category: 'حيوانات',
      kind: ProductKind.animal,
      rating: 4.8,
      reviews: 18,
      sales: 21,
      description: 'عجل محلي بحالة جيدة من بائع موثوق.',
    ),
  ];

  static const auctions = <Auction>[
    Auction(
      id: 'reference-auction-sheep',
      title: 'خروف نعيمي أصيل',
      image: 'assets/images/home/najdi_sheep.png',
      currentBid: 3950,
      remaining: Duration(hours: 2, minutes: 14),
      category: 'حيوانات',
      bidCount: 24,
      description: 'خروف أصيل موثق وجاهز للاستلام.',
    ),
    Auction(
      id: 'reference-auction-honey',
      title: 'عسل سدر فاخر',
      image: 'assets/images/home/sidr_honey.png',
      currentBid: 1500,
      remaining: Duration(hours: 5, minutes: 40),
      category: 'منتجات النحل',
      bidCount: 17,
      description: 'دفعة عسل سدر طبيعي من منحل موثوق.',
    ),
    Auction(
      id: 'reference-auction-calf',
      title: 'عجل محلي مميز',
      image: 'assets/images/home/local_calf.png',
      currentBid: 5600,
      remaining: Duration(hours: 8, minutes: 25),
      category: 'حيوانات',
      bidCount: 31,
      description: 'عجل محلي مع بيانات صحية موثقة.',
    ),
    Auction(
      id: 'reference-auction-dates',
      title: 'محصول تمر فاخر',
      image: 'assets/images/home/dates.png',
      currentBid: 8500,
      remaining: Duration(hours: 14, minutes: 36),
      category: 'منتجات زراعية',
      bidCount: 12,
      description: 'محصول تمر موسمي بجودة ممتازة.',
    ),
  ];

  static List<CartLine> get cart => <CartLine>[
        CartLine(products[0], 1),
        CartLine(products[2], 1),
        CartLine(products[1], 2),
      ];

  static List<AppOrder> get orders => <AppOrder>[
        AppOrder(
          id: '24581',
          status: 'قيد التوصيل',
          total: 5240,
          products: [products[0], products[1]],
          date: DateTime(2026, 9, 16),
        ),
        AppOrder(
          id: '24563',
          status: 'مكتمل',
          total: 1500,
          products: [products[3]],
          date: DateTime(2026, 9, 11),
        ),
      ];
}
