import '../../../core/network/api_client.dart';

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.currency,
    required this.accountNumber,
  });

  final double balance;
  final String currency;
  final String accountNumber;
}

class WalletTransactionData {
  const WalletTransactionData({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.referenceId,
    required this.createdAt,
  });

  final int id;
  final double amount;
  final int type;
  final String description;
  final String referenceId;
  final DateTime? createdAt;

  bool get isCredit => type == 1;
}

class AccountAddress {
  const AccountAddress({
    required this.id,
    required this.city,
    required this.street,
    required this.details,
    required this.isDefault,
  });

  final int id;
  final String city;
  final String street;
  final String details;
  final bool isDefault;

  String get label => [city, street, details]
      .where((value) => value.trim().isNotEmpty)
      .join('، ');
}

class AccountRepository {
  AccountRepository(this.client);
  final ApiClient client;

  Future<WalletSummary> fetchWallet() async {
    final map = jsonMap(await client.get('/api/wallets/me'));
    return WalletSummary(
      balance: _double(jsonValue(map, 'balance')),
      currency: '${jsonValue(map, 'currency') ?? ''}',
      accountNumber: '${jsonValue(map, 'accountNumber') ?? ''}',
    );
  }

  Future<List<WalletTransactionData>> fetchWalletTransactions() async {
    final response = await client.get('/api/wallets/transactions');
    if (response is! List) return const [];
    return response.map((row) {
      final map = jsonMap(row);
      return WalletTransactionData(
        id: _int(jsonValue(map, 'id')),
        amount: _double(jsonValue(map, 'amount')),
        type: _int(jsonValue(map, 'type')),
        description: '${jsonValue(map, 'description') ?? ''}',
        referenceId: '${jsonValue(map, 'referenceId') ?? ''}',
        createdAt: DateTime.tryParse('${jsonValue(map, 'createdAt') ?? ''}'),
      );
    }).toList();
  }

  Future<List<AccountAddress>> fetchAddresses() async {
    final response = await client.get('/api/Addresses/my');
    if (response is! List) return const [];
    return response.map((row) {
      final map = jsonMap(row);
      return AccountAddress(
        id: _int(jsonValue(map, 'id')),
        city: '${jsonValue(map, 'city') ?? ''}',
        street: '${jsonValue(map, 'street') ?? ''}',
        details: '${jsonValue(map, 'details') ?? ''}',
        isDefault: _bool(jsonValue(map, 'isDefault')),
      );
    }).where((address) => address.id > 0).toList()
      ..sort((a, b) {
        if (a.isDefault == b.isDefault) return a.id.compareTo(b.id);
        return a.isDefault ? -1 : 1;
      });
  }

  Future<void> deleteAddress(int id) => client.delete('/api/Addresses/$id');

  Future<void> setDefaultAddress(int id) =>
      client.put('/api/Addresses/$id/default');

  Future<Map<String, dynamic>> createWalletTopUp(double amount) async {
    return jsonMap(await client.post('/api/wallets/top-up', body: {
      'amount': amount,
    }));
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
