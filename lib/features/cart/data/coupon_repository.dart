import '../../../core/network/api_client.dart';
import '../domain/coupon.dart';

class CouponRepository {
  const CouponRepository(this.client);

  final ApiClient client;

  Future<List<Coupon>> getCoupons() async {
    final response = await client.get('/api/Coupons');
    final items = _extractList(response);
    return items.map((item) => Coupon.fromJson(jsonMap(item))).toList();
  }

  Future<Coupon> getCoupon(int id) async {
    final response = await client.get('/api/Coupons/$id');
    return Coupon.fromJson(jsonMap(response));
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      final map = jsonMap(response);
      for (final key in const ['items', 'data', 'coupons', 'results']) {
        final value = jsonValue(map, key);
        if (value is List) return value;
      }
    }
    return const [];
  }
}
