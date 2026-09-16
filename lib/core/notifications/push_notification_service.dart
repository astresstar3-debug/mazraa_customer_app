import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../network/api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService(this.client);

  final ApiClient client;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  String? _registeredToken;
  void Function(RemoteMessage message)? onForegroundMessage;
  void Function(RemoteMessage message)? onOpenedMessage;

  Future<void> initialize() async {
    await _messaging.setAutoInitEnabled(true);
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _tokenSubscription?.cancel();
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      if (client.accessToken == null || client.accessToken!.isEmpty) return;
      await registerCurrentToken(tokenOverride: token);
    });

    await _messageSubscription?.cancel();
    _messageSubscription = FirebaseMessaging.onMessage.listen((message) {
      onForegroundMessage?.call(message);
    });

    await _openedSubscription?.cancel();
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onOpenedMessage?.call(message);
    });
  }

  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  Future<void> registerCurrentToken({String? tokenOverride}) async {
    if (client.accessToken == null || client.accessToken!.isEmpty) return;
    final token = tokenOverride ?? await _messaging.getToken();
    if (token == null || token.trim().isEmpty) return;
    await client.post('/api/device-tokens/register', body: {
      'token': token,
      'deviceType': Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : Platform.operatingSystem,
      'deviceName': 'mazraa_customer_app',
    });
    _registeredToken = token;
  }

  Future<void> unregisterCurrentToken() async {
    final token = _registeredToken ?? await _messaging.getToken();
    if (token == null || token.trim().isEmpty) return;
    if (client.accessToken != null && client.accessToken!.isNotEmpty) {
      try {
        await client.delete('/api/device-tokens/${Uri.encodeComponent(token)}');
      } catch (_) {
        // Logout must remain possible even if unregistering a stale token fails.
      }
    }
    _registeredToken = null;
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
  }
}
