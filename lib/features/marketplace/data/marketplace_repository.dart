import '../domain/marketplace_models.dart';

abstract interface class MarketplaceRepository {
  List<Product> get products;
  List<Auction> get auctions;
  List<String> get categories;
  List<AppOrder> get orders;
}

class LocalMarketplaceRepository implements MarketplaceRepository {
  const LocalMarketplaceRepository();
  static const _honey = 'assets/images/home/sidr_honey.png';
  static const _dates = 'assets/images/home/dates.png';
  static const _seedlings = 'assets/images/home/date_seedlings.png';
  static const _feed = 'assets/images/home/livestock_feed.png';
  static const _calf = 'assets/images/home/local_calf.png';
  static const _sheep = 'assets/images/home/najdi_sheep.png';
  static const _herbs = 'assets/images/home/fresh_herbs.png';

  @override
  List<String> get categories => const [
    'مزادات',
    'التسوق',
    'حيوانات',
    'زراعة',
    'بذور',
    'أسمدة',
    'معدات',
    'أدوية بيطرية',
    'أعلاف',
    'مستلزمات النحل',
  ];

  @override
  List<Product> get products => const [
    Product(
      id: 'honey',
      name: 'عسل سدر طبيعي',
      image: _honey,
      price: 145,
      oldPrice: 180,
      discount: 20,
      category: 'مستلزمات النحل',
    ),
    Product(
      id: 'dates',
      name: 'تمر خلاص فاخر',
      image: _dates,
      price: 85,
      oldPrice: 100,
      discount: 15,
      category: 'منتجات زراعية',
    ),
    Product(
      id: 'seedlings',
      name: 'شتلات نخيل التمر',
      image: _seedlings,
      price: 320,
      category: 'شتلات وبذور',
    ),
    Product(
      id: 'feed',
      name: 'علف مواشي عالي الجودة',
      image: _feed,
      price: 185,
      kind: ProductKind.feed,
      category: 'أعلاف',
    ),
    Product(
      id: 'calf',
      name: 'عجل بلدي',
      image: _calf,
      price: 4500,
      oldPrice: 5500,
      discount: 18,
      kind: ProductKind.animal,
      category: 'حيوانات',
    ),
    Product(
      id: 'sheep',
      name: 'خروف نعيمي أصيل',
      image: _sheep,
      price: 3850,
      kind: ProductKind.animal,
      category: 'حيوانات',
    ),
    Product(
      id: 'herbs',
      name: 'أعشاب زراعية طازجة',
      image: _herbs,
      price: 25,
      category: 'محاصيل',
    ),
    Product(
      id: 'medicine',
      name: 'دواء بيطري مضاد للطفيليات',
      image: _feed,
      price: 96,
      oldPrice: 120,
      discount: 20,
      kind: ProductKind.medicine,
      category: 'أدوية بيطرية',
    ),
    Product(
      id: 'beehive',
      name: 'خلية نحل خشبية',
      image: _honey,
      price: 550,
      oldPrice: 700,
      kind: ProductKind.supply,
      category: 'مستلزمات النحل',
    ),
    Product(
      id: 'fertilizer',
      name: 'سماد عضوي عالي الجودة',
      image: _herbs,
      price: 120,
      kind: ProductKind.supply,
      category: 'أسمدة',
    ),
  ];

  @override
  List<Auction> get auctions => const [
    Auction(
      id: 'a-sheep',
      title: 'خروف نعيمي أصيل',
      image: _sheep,
      currentBid: 3850,
      remaining: Duration(hours: 2, minutes: 14, seconds: 36),
      category: 'حيوانات',
      bidCount: 24,
    ),
    Auction(
      id: 'a-dates',
      title: 'محصول تمر خلاص فاخر',
      image: _dates,
      currentBid: 8500,
      remaining: Duration(hours: 4, minutes: 32, seconds: 17),
      category: 'منتجات زراعية',
      bidCount: 12,
    ),
    Auction(
      id: 'a-honey',
      title: 'خلية نحل كاملة',
      image: _honey,
      currentBid: 1280,
      remaining: Duration(minutes: 45, seconds: 22),
      category: 'مستلزمات النحل',
      bidCount: 18,
    ),
    Auction(
      id: 'a-tractor',
      title: 'جرار زراعي صغير',
      image: _seedlings,
      currentBid: 28500,
      remaining: Duration(minutes: 18, seconds: 56),
      category: 'معدات زراعية',
      bidCount: 31,
    ),
  ];

  @override
  List<AppOrder> get orders => [
    AppOrder(
      id: 'MZ-24581',
      status: 'قيد التوصيل',
      total: 5240,
      products: products.take(3).toList(),
      date: DateTime(2026, 9, 12),
    ),
    AppOrder(
      id: 'MZ-24563',
      status: 'مكتمل',
      total: 4520,
      products: products.skip(1).take(3).toList(),
      date: DateTime(2026, 9, 8),
    ),
  ];
}
