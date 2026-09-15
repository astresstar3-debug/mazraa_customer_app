import '../../../core/network/api_client.dart';

class CustomerOrderItemData {
  const CustomerOrderItemData({
    required this.id,
    required this.variantId,
    required this.productName,
    required this.price,
    required this.quantity,
  });
  final int id;
  final int variantId;
  final String productName;
  final double price;
  final int quantity;
}

class CustomerOrderData {
  const CustomerOrderData({
    required this.id,
    required this.addressId,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.items,
  });
  final int id;
  final int addressId;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;
  final List<CustomerOrderItemData> items;
}

class OrderTrackingData {
  const OrderTrackingData({
    required this.orderId,
    required this.shipmentId,
    required this.shipmentNumber,
    required this.status,
    required this.driverName,
    required this.driverPhone,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });
  final int orderId;
  final int shipmentId;
  final String shipmentNumber;
  final String status;
  final String driverName;
  final String driverPhone;
  final double? latitude;
  final double? longitude;
  final DateTime? recordedAt;
}

class CustomerReturnData {
  const CustomerReturnData({
    required this.id,
    required this.orderId,
    required this.type,
    required this.reason,
    required this.status,
    required this.refundAmount,
    required this.requestedAt,
    required this.items,
  });
  final int id;
  final int orderId;
  final String type;
  final String reason;
  final String status;
  final double refundAmount;
  final DateTime? requestedAt;
  final List<Map<String, dynamic>> items;
}

class SupportFaqData {
  const SupportFaqData({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });
  final int id;
  final String question;
  final String answer;
  final String category;
}

class SupportTicketData {
  const SupportTicketData({
    required this.id,
    required this.number,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.lastMessage,
    required this.createdAt,
  });
  final int id;
  final String number;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final String lastMessage;
  final DateTime? createdAt;
}

class ProductReviewData {
  const ProductReviewData({
    required this.id,
    required this.userName,
    required this.rating,
    required this.title,
    required this.text,
    required this.createdAt,
  });
  final int id;
  final String userName;
  final double rating;
  final String title;
  final String text;
  final DateTime? createdAt;
}

class CustomerServiceRepository {
  CustomerServiceRepository(this.client);
  final ApiClient client;

  Future<CustomerOrderData> fetchOrder(int id) async {
    final map = jsonMap(await client.get('/api/Orders/$id'));
    return _order(map);
  }

  Future<void> cancelOrder(int id) => client.post('/api/Orders/$id/cancel');

  Future<OrderTrackingData> fetchTracking(int id) async {
    final map = jsonMap(await client.get('/api/orders/$id/tracking'));
    final driver = jsonValue(map, 'driver');
    final driverMap = driver is Map ? jsonMap(driver) : <String, dynamic>{};
    final last = jsonValue(map, 'lastLocation');
    final lastMap = last is Map ? jsonMap(last) : <String, dynamic>{};
    return OrderTrackingData(
      orderId: _int(jsonValue(map, 'orderId')),
      shipmentId: _int(jsonValue(map, 'shipmentId')),
      shipmentNumber: '${jsonValue(map, 'shipmentNumber') ?? ''}',
      status: '${jsonValue(map, 'status') ?? ''}',
      driverName: '${jsonValue(driverMap, 'name') ?? ''}',
      driverPhone: '${jsonValue(driverMap, 'phone') ?? ''}',
      latitude: _nullableDouble(jsonValue(lastMap, 'latitude')),
      longitude: _nullableDouble(jsonValue(lastMap, 'longitude')),
      recordedAt: DateTime.tryParse('${jsonValue(lastMap, 'recordedAt') ?? ''}'),
    );
  }

  Future<void> rateOrder({
    required int orderId,
    required double deliveryRating,
    required double storeRating,
    required String comment,
  }) => client.post('/api/orders/$orderId/rate', body: {
        'deliveryRating': deliveryRating,
        'storeRating': storeRating,
        'comment': comment.trim(),
      });

  Future<void> createReturn({
    required int orderId,
    required String reason,
    required List<CustomerOrderItemData> items,
  }) => client.post('/api/orders/$orderId/return', body: {
        'reason': reason.trim(),
        'items': items
            .map((item) => {
                  'orderItemId': item.id,
                  'quantity': item.quantity,
                  'reason': reason.trim(),
                })
            .toList(),
      });

  Future<List<CustomerReturnData>> fetchReturns() async {
    final response = await client.get('/api/returns');
    if (response is! List) return const [];
    return response.map((row) {
      final map = jsonMap(row);
      final items = jsonValue(map, 'items');
      return CustomerReturnData(
        id: _int(jsonValue(map, 'id')),
        orderId: _int(jsonValue(map, 'orderId')),
        type: '${jsonValue(map, 'type') ?? ''}',
        reason: '${jsonValue(map, 'reason') ?? ''}',
        status: '${jsonValue(map, 'status') ?? ''}',
        refundAmount: _double(jsonValue(map, 'refundAmount')),
        requestedAt: DateTime.tryParse('${jsonValue(map, 'requestedAt') ?? ''}'),
        items: items is List ? items.map((item) => jsonMap(item)).toList() : const [],
      );
    }).toList();
  }

  Future<List<SupportFaqData>> fetchFaqs() async {
    final response = await client.get('/api/support/faqs');
    if (response is! List) return const [];
    return response.map((row) {
      final map = jsonMap(row);
      return SupportFaqData(
        id: _int(jsonValue(map, 'id')),
        question: '${jsonValue(map, 'question') ?? ''}',
        answer: '${jsonValue(map, 'answer') ?? ''}',
        category: '${jsonValue(map, 'category') ?? ''}',
      );
    }).toList();
  }

  Future<List<SupportTicketData>> fetchTickets() async {
    final response = await client.get('/api/support/tickets');
    if (response is! List) return const [];
    return response.map((row) {
      final map = jsonMap(row);
      return SupportTicketData(
        id: _int(jsonValue(map, 'id')),
        number: '${jsonValue(map, 'number') ?? ''}',
        subject: '${jsonValue(map, 'subject') ?? ''}',
        category: '${jsonValue(map, 'category') ?? ''}',
        priority: '${jsonValue(map, 'priority') ?? ''}',
        status: '${jsonValue(map, 'status') ?? ''}',
        lastMessage: '${jsonValue(map, 'lastMessage') ?? ''}',
        createdAt: DateTime.tryParse('${jsonValue(map, 'createdAt') ?? ''}'),
      );
    }).toList();
  }

  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String message,
    String priority = 'normal',
  }) async => jsonMap(await client.post('/api/support/tickets', body: {
        'subject': subject.trim(),
        'message': message.trim(),
        'priority': priority,
      }));

  Future<int> startSupportChat() async {
    final map = jsonMap(await client.post('/api/support/live-chat'));
    return _int(jsonValue(map, 'chatId'));
  }

  Future<List<ProductReviewData>> fetchProductReviews(int productId) async {
    final map = jsonMap(await client.get('/api/Reviews', query: {
      'productId': productId,
      'page': 1,
      'perPage': 100,
    }));
    final data = jsonValue(map, 'data');
    if (data is! List) return const [];
    return data.map((row) {
      final item = jsonMap(row);
      return ProductReviewData(
        id: _int(jsonValue(item, 'id')),
        userName: '${jsonValue(item, 'userName') ?? ''}',
        rating: _double(jsonValue(item, 'rating')),
        title: '${jsonValue(item, 'title') ?? ''}',
        text: '${jsonValue(item, 'reviewText') ?? ''}',
        createdAt: DateTime.tryParse('${jsonValue(item, 'createdAt') ?? ''}'),
      );
    }).toList();
  }

  Future<void> createProductReview({
    required int productId,
    required double rating,
    required String title,
    required String text,
  }) => client.post('/api/Reviews', body: {
        'productId': productId,
        'rating': rating,
        'title': title.trim(),
        'reviewText': text.trim(),
      });

  static CustomerOrderData _order(Map<String, dynamic> map) {
    final items = jsonValue(map, 'items');
    return CustomerOrderData(
      id: _int(jsonValue(map, 'id')),
      addressId: _int(jsonValue(map, 'addressId')),
      totalPrice: _double(jsonValue(map, 'totalPrice')),
      status: '${jsonValue(map, 'status') ?? ''}',
      createdAt: DateTime.tryParse('${jsonValue(map, 'createdAt') ?? ''}'),
      items: items is List
          ? items.map((row) {
              final item = jsonMap(row);
              return CustomerOrderItemData(
                id: _int(jsonValue(item, 'id')),
                variantId: _int(jsonValue(item, 'itemId')),
                productName: '${jsonValue(item, 'productName') ?? ''}',
                price: _double(jsonValue(item, 'price')),
                quantity: _int(jsonValue(item, 'quantity')),
              );
            }).toList()
          : const [],
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }
}
