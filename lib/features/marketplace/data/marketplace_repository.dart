import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../domain/marketplace_models.dart';

class MarketplaceRepository {
  MarketplaceRepository(this.client);

  final ApiClient client;
  final List<String> _categories = <String>[];

  List<String> get categories => List.unmodifiable(_categories);
  List<AppOrder> get orders => const <AppOrder>[];

  Future<List<Product>> fetchProducts({
    String? query,
    String sort = 'best_selling',
    int page = 1,
    int perPage = 100,
  }) async {
    final responses = await Future.wait<dynamic>([
      client.get('/api/search', query: {
        'q': query ?? '',
        'sort': sort,
        'page': page,
        'perPage': perPage,
      }),
      client.get('/api/Products'),
      client.get('/api/product-variants'),
    ]);

    final searchRoot = jsonMap(responses[0]);
    final cards = _asList(jsonValue(searchRoot, 'data'));
    final productRows = _asList(responses[1]);
    final variantRows = _asList(responses[2]);

    final detailsById = <int, Map<String, dynamic>>{};
    for (final row in productRows) {
      final map = jsonMap(row);
      final id = _asInt(jsonValue(map, 'id'));
      if (id != null) detailsById[id] = map;
    }

    final variantsByProduct = <int, List<Map<String, dynamic>>>{};
    for (final row in variantRows) {
      final map = jsonMap(row);
      final productId = _asInt(jsonValue(map, 'productId'));
      if (productId == null) continue;
      variantsByProduct.putIfAbsent(productId, () => []).add(map);
    }

    return cards.map((row) {
      final card = jsonMap(row);
      final id = _asInt(jsonValue(card, 'id')) ?? 0;
      final detail = detailsById[id] ?? const <String, dynamic>{};
      final variants = variantsByProduct[id] ?? const <Map<String, dynamic>>[];
      final available = variants.where(
        (v) => _asBool(jsonValue(v, 'isAvailable')) ?? false,
      ).toList();
      final selectedVariant = available.isNotEmpty
          ? available.first
          : (variants.isNotEmpty ? variants.first : null);

      final price = _asDouble(jsonValue(card, 'price')) ??
          _variantEffectivePrice(selectedVariant) ??
          0;
      final regularPrice = _asDouble(jsonValue(card, 'regularPrice')) ??
          _asDouble(selectedVariant == null ? null : jsonValue(selectedVariant, 'price'));
      final oldPrice = regularPrice != null && regularPrice > price
          ? regularPrice
          : null;
      final discount = oldPrice == null || oldPrice <= 0
          ? null
          : (((oldPrice - price) / oldPrice) * 100).round();

      final detailImages = _imageUrls(jsonValue(detail, 'images'));
      final variantImages = selectedVariant == null
          ? const <String>[]
          : _imageUrls(jsonValue(selectedVariant, 'images'));
      final thumbnail = _asString(jsonValue(card, 'thumbnail'));
      final allImages = <String>{
        if (thumbnail != null && thumbnail.isNotEmpty)
          ApiConfig.resolveMediaUrl(thumbnail),
        ...detailImages,
        ...variantImages,
      }.where((e) => e.isNotEmpty).toList();

      return Product(
        id: '$id',
        variantId: selectedVariant == null
            ? null
            : _asInt(jsonValue(selectedVariant, 'id')),
        name: _asString(jsonValue(card, 'name')) ??
            _asString(jsonValue(detail, 'name')) ??
            '',
        image: allImages.isEmpty ? '' : allImages.first,
        images: allImages,
        price: price,
        oldPrice: oldPrice,
        discount: discount,
        category: _asString(jsonValue(detail, 'subCategory')) ?? '',
        rating: _asDouble(jsonValue(card, 'rating')) ?? 0,
        reviews: 0,
        description: _asString(jsonValue(card, 'description')) ??
            _asString(jsonValue(detail, 'description')) ??
            '',
        inStock: _asBool(jsonValue(card, 'inStock')) ?? false,
        sales: _asInt(jsonValue(card, 'sales')) ?? 0,
        kind: _kindFrom(
          '${_asString(jsonValue(detail, 'type')) ?? ''} ${_asString(jsonValue(detail, 'subCategory')) ?? ''}',
        ),
      );
    }).where((product) => product.id != '0').toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await client.get('/api/Categories');
    final result = _asList(response)
        .map((row) => _asString(jsonValue(jsonMap(row), 'name')) ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    _categories
      ..clear()
      ..addAll(result);
    return List.unmodifiable(_categories);
  }

  Future<List<Auction>> fetchAuctions() async {
    final response = await client.get('/api/Auctions/discover', query: {
      'sort': 'ending_soon',
      'page': 1,
      'perPage': 50,
    });
    final root = jsonMap(response);
    final now = DateTime.now();
    return _asList(jsonValue(root, 'data')).map((row) {
      final map = jsonMap(row);
      final endAt = DateTime.tryParse(_asString(jsonValue(map, 'endAt')) ?? '');
      final startAt = DateTime.tryParse(_asString(jsonValue(map, 'startAt')) ?? '');
      var remaining = endAt == null ? Duration.zero : endAt.difference(now);
      if (remaining.isNegative) remaining = Duration.zero;
      final state = endAt != null && endAt.isBefore(now)
          ? AuctionState.ended
          : (startAt != null && startAt.isAfter(now)
              ? AuctionState.upcoming
              : AuctionState.live);
      return Auction(
        id: '${_asInt(jsonValue(map, 'id')) ?? 0}',
        title: _asString(jsonValue(map, 'title')) ?? '',
        description: _asString(jsonValue(map, 'description')) ?? '',
        image: ApiConfig.resolveMediaUrl(_asString(jsonValue(map, 'image'))),
        currentBid: _asDouble(jsonValue(map, 'currentPrice')) ?? 0,
        remaining: remaining,
        category: '',
        bidCount: _asInt(jsonValue(map, 'bidCount')) ?? 0,
        state: state,
      );
    }).where((auction) => auction.id != '0').toList();
  }

  Future<List<CartLine>> fetchCart(List<Product> knownProducts) async {
    final response = jsonMap(await client.get('/api/Carts'));
    final items = _asList(jsonValue(response, 'items'));
    return items.map((row) {
      final map = jsonMap(row);
      final productId = _asInt(jsonValue(map, 'productId'));
      final variantId = _asInt(jsonValue(map, 'productVariantId'));
      final existing = knownProducts.cast<Product?>().firstWhere(
            (p) => p?.id == '$productId',
            orElse: () => null,
          );
      final image = ApiConfig.resolveMediaUrl(_asString(jsonValue(map, 'image')));
      final product = existing ??
          Product(
            id: '${productId ?? variantId ?? 0}',
            variantId: variantId,
            name: _asString(jsonValue(map, 'productName')) ??
                _asString(jsonValue(map, 'variantName')) ??
                '',
            image: image,
            images: image.isEmpty ? const [] : [image],
            price: _asDouble(jsonValue(map, 'price')) ?? 0,
            category: '',
          );
      return CartLine(
        product,
        _asInt(jsonValue(map, 'quantity')) ?? 1,
        cartItemId: _asInt(jsonValue(map, 'id')),
      );
    }).toList();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final variantId = product.variantId;
    if (variantId == null) {
      throw const ApiException('لا يوجد عنصر متاح لهذا المنتج حاليًا.');
    }
    await client.post('/api/Carts/add', body: {
      'productVariantId': variantId,
      'quantity': quantity,
    });
  }

  Future<void> updateCartItem(int cartItemId, int quantity) async {
    await client.put('/api/Carts/item/$cartItemId', query: {'quantity': quantity});
  }

  Future<void> removeCartItem(int cartItemId) async {
    await client.delete('/api/Carts/item/$cartItemId');
  }

  static List<dynamic> _asList(dynamic value) => value is List ? value : const [];

  static String? _asString(dynamic value) => value == null ? null : '$value';

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if ('$value'.toLowerCase() == 'true') return true;
    if ('$value'.toLowerCase() == 'false') return false;
    return null;
  }

  static double? _variantEffectivePrice(Map<String, dynamic>? variant) {
    if (variant == null) return null;
    return _asDouble(jsonValue(variant, 'salePrice')) ??
        _asDouble(jsonValue(variant, 'price'));
  }

  static List<String> _imageUrls(dynamic value) => _asList(value)
      .map((row) {
        if (row is String) return ApiConfig.resolveMediaUrl(row);
        final map = jsonMap(row);
        return ApiConfig.resolveMediaUrl(
          _asString(jsonValue(map, 'imageUrl')) ??
              _asString(jsonValue(map, 'mediaUrl')),
        );
      })
      .where((url) => url.isNotEmpty)
      .toList();

  static ProductKind _kindFrom(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('حيوان') || value.contains('animal')) {
      return ProductKind.animal;
    }
    if (value.contains('دواء') ||
        value.contains('بيطر') ||
        value.contains('medicine')) {
      return ProductKind.medicine;
    }
    if (value.contains('علف') || value.contains('feed')) {
      return ProductKind.feed;
    }
    if (value.contains('مستلزم') ||
        value.contains('معدات') ||
        value.contains('supply')) {
      return ProductKind.supply;
    }
    return ProductKind.crop;
  }
}
