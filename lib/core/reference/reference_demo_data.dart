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
      reviews: 126,
      discount: 20,
      sales: 184,
      description: 'عسل سدر طبيعي 100% مستخرج من أزهار شجرة السدر في بيئة نقية، يتميز بطعمه الغني وفوائده الصحية العالية.',
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
      description: 'خلطة أعلاف متوازنة مخصصة للمواشي وتحتوي على مكونات غذائية مختارة.',
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
      id: 'reference-product-medicine',
      name: 'لقاح بيطري متعدد الاستخدام',
      image: 'assets/images/home/local_calf.png',
      images: ['assets/images/home/local_calf.png'],
      price: 95,
      oldPrice: 110,
      category: 'الأدوية البيطرية',
      kind: ProductKind.medicine,
      rating: 4.7,
      reviews: 38,
      discount: 14,
      sales: 76,
      description: 'منتج بيطري مخصص للعناية بالحيوانات ويستخدم وفق إرشادات المنتج والمختص البيطري.',
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

  static const _cartHoney = Product(
    id: 'reference-cart-honey',
    name: 'عسل سدر طبيعي',
    image: 'assets/images/home/sidr_honey.png',
    images: ['assets/images/home/sidr_honey.png'],
    price: 4500,
    category: 'منتجات النحل',
    rating: 4.8,
    reviews: 126,
  );

  static const _cartTomatoSeeds = Product(
    id: 'reference-cart-tomato-seeds',
    name: 'بذور طماطم هجينة',
    image: 'assets/images/home/date_seedlings.png',
    images: ['assets/images/home/date_seedlings.png'],
    price: 85,
    category: 'بذور',
    rating: 4.7,
    reviews: 52,
  );

  static const _cartBeekeeperSuit = Product(
    id: 'reference-cart-beekeeper-suit',
    name: 'بدلة نحال واقية',
    image: 'assets/images/home/sidr_honey.png',
    images: ['assets/images/home/sidr_honey.png'],
    price: 4500,
    category: 'مستلزمات النحل',
    kind: ProductKind.supply,
    rating: 4.9,
    reviews: 31,
  );

  static const auctions = <Auction>[
    Auction(
      id: 'reference-auction-sheep',
      title: 'خروف نعيمي',
      image: 'assets/images/home/najdi_sheep.png',
      currentBid: 2450,
      remaining: Duration(hours: 1, minutes: 12, seconds: 36),
      category: 'حيوانات',
      bidCount: 12,
      state: AuctionState.live,
      description: 'خروف نعيمي موثق وجاهز للاستلام، بحالة ممتازة ومن بائع موثوق.',
    ),
    Auction(
      id: 'reference-auction-hive',
      title: 'خلية نحل كاملة',
      image: 'assets/images/home/sidr_honey.png',
      currentBid: 1280,
      remaining: Duration(minutes: 45, seconds: 22),
      category: 'مستلزمات النحل',
      bidCount: 8,
      state: AuctionState.live,
      description: 'خلية نحل متكاملة مع المستلزمات الأساسية من منحل موثوق.',
    ),
    Auction(
      id: 'reference-auction-tractor',
      title: 'جرار زراعي صغير',
      image: 'assets/images/home/date_seedlings.png',
      currentBid: 5600,
      remaining: Duration(days: 1),
      category: 'معدات',
      bidCount: 0,
      state: AuctionState.upcoming,
      description: 'معدات زراعية مخصصة للأعمال الخفيفة في المزارع الصغيرة.',
    ),
    Auction(
      id: 'reference-auction-bee-box',
      title: 'صندوق تربية النحل',
      image: 'assets/images/home/sidr_honey.png',
      currentBid: 680,
      remaining: Duration(days: 2),
      category: 'مستلزمات النحل',
      bidCount: 0,
      state: AuctionState.upcoming,
      description: 'صندوق مناسب لتربية النحل ومجهز للاستخدام في المناحل.',
    ),
  ];

  static List<CartLine> get cart => <CartLine>[
        const CartLine(_cartHoney, 1),
        const CartLine(_cartTomatoSeeds, 1),
        const CartLine(_cartBeekeeperSuit, 1),
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
