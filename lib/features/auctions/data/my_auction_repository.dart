import '../../../core/network/api_client.dart';

class MyAuctionBidData {
  const MyAuctionBidData({
    required this.id,
    required this.auctionItemId,
    required this.auctionId,
    required this.auctionTitle,
    required this.animalName,
    required this.bidAmount,
    required this.currentPrice,
    required this.auctionStatus,
    required this.isWinner,
    required this.bidAt,
  });

  final int id;
  final int auctionItemId;
  final int auctionId;
  final String auctionTitle;
  final String animalName;
  final double bidAmount;
  final double currentPrice;
  final String auctionStatus;
  final bool isWinner;
  final DateTime? bidAt;
}

class MyAuctionRepository {
  MyAuctionRepository(this.client);
  final ApiClient client;

  Future<List<MyAuctionBidData>> fetchMine({String? result}) async {
    final response = await client.get('/api/AuctionBids/mine', query: {
      if (result != null && result.isNotEmpty) 'result': result,
    });
    if (response is! List) return const [];
    return response.map((row) {
      final map = jsonMap(row);
      return MyAuctionBidData(
        id: _int(jsonValue(map, 'id')),
        auctionItemId: _int(jsonValue(map, 'auctionItemId')),
        auctionId: _int(jsonValue(map, 'auctionId')),
        auctionTitle: '${jsonValue(map, 'auctionTitle') ?? ''}',
        animalName: '${jsonValue(map, 'animalName') ?? ''}',
        bidAmount: _double(jsonValue(map, 'bidAmount')),
        currentPrice: _double(jsonValue(map, 'currentPrice')),
        auctionStatus: '${jsonValue(map, 'auctionStatus') ?? ''}',
        isWinner: _bool(jsonValue(map, 'isWinner')),
        bidAt: DateTime.tryParse('${jsonValue(map, 'bidAt') ?? ''}'),
      );
    }).where((item) => item.id > 0).toList();
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

  static bool _bool(dynamic value) =>
      value is bool ? value : '$value'.toLowerCase() == 'true';
}
