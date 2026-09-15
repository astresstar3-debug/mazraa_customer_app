import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredSession {
  const StoredSession({
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

class SessionStorage {
  const SessionStorage();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';
  static const _userIdKey = 'auth.user_id';
  static const _emailKey = 'auth.email';
  static const _rolesKey = 'auth.roles';

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required int? userId,
    required String email,
    required List<String> roles,
  }) async {
    await Future.wait<void>([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId?.toString() ?? ''),
      _storage.write(key: _emailKey, value: email),
      _storage.write(key: _rolesKey, value: roles.join('|')),
    ]);
  }

  Future<StoredSession?> read() async {
    final values = await Future.wait<String?>([
      _storage.read(key: _accessKey),
      _storage.read(key: _refreshKey),
      _storage.read(key: _userIdKey),
      _storage.read(key: _emailKey),
      _storage.read(key: _rolesKey),
    ]);
    final refresh = values[1]?.trim() ?? '';
    if (refresh.isEmpty) return null;
    final rolesRaw = values[4]?.trim() ?? '';
    return StoredSession(
      accessToken: values[0]?.trim() ?? '',
      refreshToken: refresh,
      userId: int.tryParse(values[2] ?? ''),
      email: values[3] ?? '',
      roles: rolesRaw.isEmpty
          ? const []
          : rolesRaw.split('|').where((e) => e.trim().isNotEmpty).toList(),
    );
  }

  Future<void> clear() async {
    await Future.wait<void>([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _rolesKey),
    ]);
  }
}
