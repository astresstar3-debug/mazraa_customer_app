import '../../../core/network/api_client.dart';
import '../domain/coupon.dart';
import 'reference_coupon_data.dart';

class CouponRepository {
  const CouponRepository(this.client);

  final ApiClient client;
  static const _requestTimeout = Duration(seconds: 12);

  Future<List<Coupon>> getCoupons() async {
    try {
      final response = await client
          .get('/api/Coupons')
          .timeout(_requestTimeout);
      final items = _extractList(response);
      final coupons = items
          .map((item) => Coupon.fromJson(jsonMap(item)))
          .where((coupon) => coupon.code.isNotEmpty)
          .toList();
      return coupons.isEmpty ? ReferenceCouponData.coupons : coupons;
    } catch (_) {
      return ReferenceCouponData.coupons;
    }
  }

  Future<Coupon> getCoupon(int id) async {
    if (id < 0) return ReferenceCouponData.byId(id);
    try {
      final response = await client
          .get('/api/Coupons/$id')
          .timeout(_requestTimeout);
      final coupon = Coupon.fromJson(jsonMap(response));
      return coupon.code.isEmpty ? ReferenceCouponData.byId(id) : coupon;
    } catch (_) {
      return ReferenceCouponData.byId(id);
    }
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
