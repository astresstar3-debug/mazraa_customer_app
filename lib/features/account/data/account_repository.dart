import '../../../core/network/api_client.dart';

class UserProfileData {
  const UserProfileData({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.emailVerified,
    required this.phoneVerified,
    required this.level,
    required this.loyaltyPoints,
    required this.roles,
    this.gender,
    this.dateOfBirth,
  });

  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String profileImageUrl;
  final bool emailVerified;
  final bool phoneVerified;
  final String level;
  final int loyaltyPoints;
  final List<String> roles;
  final int? gender;
  final DateTime? dateOfBirth;

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    final composed = '$firstName $lastName'.trim();
    return composed.isNotEmpty ? composed : email;
  }
}

class UserPreferenceData {
  const UserPreferenceData({
    required this.push,
    required this.email,
    required this.sms,
    required this.marketing,
    required this.language,
    required this.shareAnalytics,
    required this.profileVisible,
  });

  final bool push;
  final bool email;
  final bool sms;
  final bool marketing;
  final String language;
  final bool shareAnalytics;
  final bool profileVisible;
}

class AccountNotificationData {
  const AccountNotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.eventType,
    required this.isRead,
    required this.createdAt,
    required this.deepLink,
  });

  final int id;
  final String title;
  final String message;
  final String eventType;
  final bool isRead;
  final DateTime? createdAt;
  final String deepLink;
}

class PaymentMethodsData {
  const PaymentMethodsData({required this.saved, required this.available});
  final List<Map<String, dynamic>> saved;
  final List<Map<String, dynamic>> available;
}

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

  Future<UserProfileData> fetchProfile() async {
    final map = jsonMap(await client.get('/api/users/me'));
    final roleValue = jsonValue(map, 'roles');
    return UserProfileData(
      id: _int(jsonValue(map, 'id')),
      name: '${jsonValue(map, 'name') ?? ''}',
      firstName: '${jsonValue(map, 'firstName') ?? ''}',
      lastName: '${jsonValue(map, 'lastName') ?? ''}',
      email: '${jsonValue(map, 'email') ?? ''}',
      phone: '${jsonValue(map, 'phone') ?? ''}',
      profileImageUrl: '${jsonValue(map, 'profileImageUrl') ?? ''}',
      emailVerified: _bool(jsonValue(map, 'emailVerified')),
      phoneVerified: _bool(jsonValue(map, 'phoneVerified')),
      level: '${jsonValue(map, 'level') ?? ''}',
      loyaltyPoints: _int(jsonValue(map, 'loyaltyPoints')),
      roles: roleValue is List
          ? roleValue.map((item) => '$item').where((item) => item.isNotEmpty).toList()
          : const [],
      gender: jsonValue(map, 'gender') == null ? null : _int(jsonValue(map, 'gender')),
      dateOfBirth: DateTime.tryParse('${jsonValue(map, 'dateOfBirth') ?? ''}'),
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String firstName = '',
    String lastName = '',
    int? gender,
    DateTime? dateOfBirth,
  }) => client.put('/api/users/me', body: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => client.put('/api/users/me/password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

  Future<UserPreferenceData> fetchSettings() async {
    final map = jsonMap(await client.get('/api/users/me/settings'));
    return UserPreferenceData(
      push: _bool(jsonValue(map, 'pushNotifications')),
      email: _bool(jsonValue(map, 'emailNotifications')),
      sms: _bool(jsonValue(map, 'smsNotifications')),
      marketing: _bool(jsonValue(map, 'marketingNotifications')),
      language: '${jsonValue(map, 'language') ?? 'ar'}',
      shareAnalytics: _bool(jsonValue(map, 'shareAnalytics')),
      profileVisible: _bool(jsonValue(map, 'profileVisible')),
    );
  }

  Future<void> updateNotificationPreferences({
    required bool push,
    required bool email,
    required bool sms,
    required bool marketing,
  }) => client.put('/api/users/me/notifications', body: {
        'push': push,
        'email': email,
        'sms': sms,
        'marketing': marketing,
      });

  Future<void> updateLanguage(String language) =>
      client.put('/api/users/me/language', body: {'language': language});

  Future<void> updatePrivacy({
    required bool shareAnalytics,
    required bool profileVisible,
  }) => client.put('/api/users/me/privacy', body: {
        'shareAnalytics': shareAnalytics,
        'profileVisible': profileVisible,
      });

  Future<PaymentMethodsData> fetchPaymentMethods() async {
    final map = jsonMap(await client.get('/api/users/me/payment-methods'));
    return PaymentMethodsData(
      saved: _mapList(jsonValue(map, 'saved')),
      available: _mapList(jsonValue(map, 'available')),
    );
  }

  Future<List<AccountNotificationData>> fetchNotifications({
    bool unreadOnly = false,
    String? eventType,
  }) async {
    final response = jsonMap(await client.get('/api/notifications', query: {
      'page': 1,
      'pageSize': 100,
      if (unreadOnly) 'unreadOnly': true,
      if (eventType != null && eventType.trim().isNotEmpty) 'eventType': eventType,
    }));
    final items = jsonValue(response, 'items');
    if (items is! List) return const [];
    return items.map((row) {
      final map = jsonMap(row);
      return AccountNotificationData(
        id: _int(jsonValue(map, 'id')),
        title: '${jsonValue(map, 'title') ?? ''}',
        message: '${jsonValue(map, 'message') ?? ''}',
        eventType: '${jsonValue(map, 'eventType') ?? ''}',
        isRead: _bool(jsonValue(map, 'isRead')),
        createdAt: DateTime.tryParse('${jsonValue(map, 'createdAt') ?? ''}'),
        deepLink: '${jsonValue(map, 'deepLink') ?? ''}',
      );
    }).where((item) => item.id > 0).toList();
  }

  Future<int> fetchUnreadNotificationCount() async {
    final map = jsonMap(await client.get('/api/notifications/unread-count'));
    return _int(jsonValue(map, 'count'));
  }

  Future<void> markNotificationsRead(Iterable<int> ids) =>
      client.post('/api/notifications/mark-read', body: ids.toList());

  Future<void> markAllNotificationsRead() =>
      client.post('/api/notifications/mark-all-read');

  Future<void> deleteNotification(int id) =>
      client.delete('/api/notifications/$id');

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

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => jsonMap(item)).toList();
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
