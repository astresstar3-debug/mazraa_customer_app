import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class Coupon {
  const Coupon({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minimumOrderAmount,
    required this.maximumDiscountAmount,
    required this.usageLimit,
    required this.usedCount,
    required this.validFrom,
    required this.validTo,
    required this.status,
    required this.imageUrl,
  });

  final int id;
  final String code;
  final String name;
  final String description;
  final int discountType;
  final double discountValue;
  final double minimumOrderAmount;
  final double maximumDiscountAmount;
  final int usageLimit;
  final int usedCount;
  final DateTime? validFrom;
  final DateTime? validTo;
  final int status;
  final String imageUrl;

  factory Coupon.fromJson(Map<String, dynamic> map) {
    num number(String key) {
      final value = jsonValue(map, key);
      if (value is num) return value;
      return num.tryParse('$value') ?? 0;
    }

    DateTime? date(String key) {
      final value = '${jsonValue(map, key) ?? ''}'.trim();
      return value.isEmpty ? null : DateTime.tryParse(value)?.toLocal();
    }

    String string(String key) => '${jsonValue(map, key) ?? ''}'.trim();

    var image = string('imageUrl');
    if (image.isEmpty) {
      final images = jsonValue(map, 'images');
      if (images is List && images.isNotEmpty) {
        final first = jsonMap(images.first);
        image = '${jsonValue(first, 'imageUrl') ?? ''}'.trim();
      }
    }

    final code = string('code');
    final name = string('name');
    return Coupon(
      id: number('id').toInt(),
      code: code,
      name: name.isEmpty ? code : name,
      description: string('description'),
      discountType: number('discountType').toInt(),
      discountValue: number('discountValue').toDouble(),
      minimumOrderAmount: number('minimumOrderAmount').toDouble(),
      maximumDiscountAmount: number('maximumDiscountAmount').toDouble(),
      usageLimit: number('usageLimit').toInt(),
      usedCount: number('usedCount').toInt(),
      validFrom: date('validFrom'),
      validTo: date('validTo'),
      status: number('status').toInt(),
      imageUrl: ApiConfig.resolveMediaUrl(image),
    );
  }

  bool get isPercentage => discountType == 1;

  String get discountLabel => isPercentage
      ? '${_clean(discountValue)}%'
      : formatPrice(discountValue);

  String get validityLabel {
    final value = validTo;
    if (value == null) return 'بدون تاريخ انتهاء محدد';
    const months = <String>[
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String get minimumOrderLabel => minimumOrderAmount <= 0
      ? 'لا يوجد حد أدنى'
      : formatPrice(minimumOrderAmount);

  String get maximumDiscountLabel => maximumDiscountAmount <= 0
      ? 'غير محدد'
      : formatPrice(maximumDiscountAmount);

  static String _clean(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
}
