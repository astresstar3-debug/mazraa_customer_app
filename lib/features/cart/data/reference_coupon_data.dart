import '../domain/coupon.dart';

/// Temporary visual fixtures used only when the development API has no coupons.
/// Real server coupons always take precedence.
abstract final class ReferenceCouponData {
  static final List<Coupon> coupons = <Coupon>[
    Coupon(
      id: -1001,
      code: 'MAZRAA25',
      name: 'خصم الموسم الزراعي',
      description: 'خصم خاص على مجموعة من المنتجات الزراعية المختارة.',
      discountType: 1,
      discountValue: 25,
      minimumOrderAmount: 150,
      maximumDiscountAmount: 100,
      usageLimit: 100,
      usedCount: 26,
      validFrom: DateTime(2026, 9, 1),
      validTo: DateTime(2026, 10, 31),
      status: 1,
      imageUrl: '',
    ),
    Coupon(
      id: -1002,
      code: 'WELCOME15',
      name: 'كوبون ترحيبي',
      description: 'استفد من خصم ترحيبي عند إتمام طلبك.',
      discountType: 1,
      discountValue: 15,
      minimumOrderAmount: 100,
      maximumDiscountAmount: 75,
      usageLimit: 200,
      usedCount: 52,
      validFrom: DateTime(2026, 9, 1),
      validTo: DateTime(2026, 12, 31),
      status: 1,
      imageUrl: '',
    ),
    Coupon(
      id: -1003,
      code: 'SAVE50',
      name: 'وفر 50 ر.س',
      description: 'خصم ثابت للطلبات التي تحقق الحد الأدنى.',
      discountType: 2,
      discountValue: 50,
      minimumOrderAmount: 300,
      maximumDiscountAmount: 50,
      usageLimit: 80,
      usedCount: 11,
      validFrom: DateTime(2026, 9, 1),
      validTo: DateTime(2026, 11, 30),
      status: 1,
      imageUrl: '',
    ),
  ];

  static Coupon byId(int id) => coupons.firstWhere(
        (coupon) => coupon.id == id,
        orElse: () => coupons.first,
      );
}
