import '../../../core/network/api_client.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.roles,
  });

  final String accessToken;
  final String refreshToken;
  final int? userId;
  final String email;
  final List<String> roles;
}

class AuthRepository {
  AuthRepository(this.client);
  final ApiClient client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = jsonMap(await client.post('/api/Auth/login', body: {
      'email': email.trim(),
      'password': password,
      'deviceName': 'mazraa_customer_app',
    }));
    return _apply(response);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = jsonMap(await client.post('/api/Auth/register', body: {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    }));
    return _apply(response);
  }

  Future<void> forgotPassword(String email) =>
      client.post('/api/auth/forgot-password', body: {'email': email.trim()});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) => client.post('/api/auth/reset-password', body: {
        'token': token.trim(),
        'newPassword': newPassword,
      });

  Future<void> requestPhoneOtp(String phone) =>
      client.post('/api/auth/phone', body: {'phoneNumber': phone.trim()});

  Future<AuthSession> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    final response = jsonMap(await client.post('/api/auth/phone/verify', body: {
      'phoneNumber': phone.trim(),
      'code': code.trim(),
    }));
    return _apply(response);
  }

  Future<void> verifyGenericOtp({
    required String key,
    required String code,
  }) => client.post('/api/auth/otp/verify', body: {
        'key': key.trim(),
        'code': code.trim(),
      });

  Future<void> verifyEmail(String token) =>
      client.post('/api/auth/email/verify', body: {'token': token.trim()});

  Future<void> resendEmailVerification(String email) => client.post(
        '/api/auth/email/resend-verification',
        body: {'email': email.trim()},
      );

  Future<void> logout() async {
    final refresh = client.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      await client.post('/api/Auth/logout', body: {'refreshToken': refresh});
    }
    client.accessToken = null;
    client.refreshToken = null;
  }

  AuthSession _apply(Map<String, dynamic> map) {
    final access = '${jsonValue(map, 'token') ?? ''}';
    final refresh = '${jsonValue(map, 'refreshToken') ?? ''}';
    if (access.isEmpty) {
      throw const ApiException('لم يُرجع الخادم رمز دخول صالحًا.');
    }
    client.accessToken = access;
    client.refreshToken = refresh;

    final rawRoles = jsonValue(map, 'roles');
    final roles = rawRoles is List
        ? rawRoles.map((e) => '$e').toList()
        : <String>[
            if (jsonValue(map, 'role') != null) '${jsonValue(map, 'role')}',
          ];
    final rawId = jsonValue(map, 'userId');
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      userId: rawId is num ? rawId.toInt() : int.tryParse('$rawId'),
      email: '${jsonValue(map, 'email') ?? ''}',
      roles: roles,
    );
  }
}
