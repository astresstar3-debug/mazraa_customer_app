import '../../../core/network/api_client.dart';
import '../../marketplace/domain/marketplace_models.dart';

class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.city,
    required this.street,
    this.details = '',
    this.isDefault = false,
  });

  final int id;
  final String city;
  final String street;
  final String details;
  final bool isDefault;

  String get label => [
        city,
        street,
        details,
      ].where((value) => value.trim().isNotEmpty).join('، ');
}

class CreatedOrder {
  const CreatedOrder({required this.id, required this.status, required this.total});
  final int id;
  final String status;
  final double total;
}

class CheckoutRepository {
  CheckoutRepository(this.client);
  final ApiClient client;

  Future<List<DeliveryAddress>> fetchAddresses() async {
    final response = await client.get('/api/Addresses/my');
    if (response is! List) return const [];
    final result = response.map((row) {
      final map = jsonMap(row);
      return DeliveryAddress(
        id: _asInt(jsonValue(map, 'id')) ?? 0,
        city: '${jsonValue(map, 'city') ?? ''}',
        street: '${jsonValue(map, 'street') ?? ''}',
        details: '${jsonValue(map, 'details') ?? ''}',
        isDefault: _asBool(jsonValue(map, 'isDefault')),
      );
    }).where((address) => address.id > 0).toList();
    result.sort((a, b) {
      if (a.isDefault == b.isDefault) return a.id.compareTo(b.id);
      return a.isDefault ? -1 : 1;
    });
    return result;
  }

  Future<CreatedOrder> createOrder({
    required int userId,
    required int addressId,
    required List<CartLine> lines,
    required int paymentMethod,
    String? couponCode,
  }) async {
    final items = lines
        .where((line) => line.product.variantId != null)
        .map(
          (line) => {
            'productVariantId': line.product.variantId,
            'quantity': line.quantity,
          },
        )
        .toList();
    if (items.isEmpty) {
      throw const ApiException('لا توجد عناصر صالحة لإنشاء الطلب.');
    }

    final response = jsonMap(await client.post('/api/Orders', body: {
      'userId': userId,
      'addressId': addressId,
      'items': items,
      'paymentMethod': paymentMethod,
      if (couponCode != null && couponCode.trim().isNotEmpty)
        'couponCode': couponCode.trim(),
    }));

    return CreatedOrder(
      id: _asInt(jsonValue(response, 'id')) ?? 0,
      status: '${jsonValue(response, 'status') ?? ''}',
      total: _asDouble(jsonValue(response, 'totalPrice')) ?? 0,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    return '$value'.toLowerCase() == 'true';
  }
}
