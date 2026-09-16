import 'package:flutter/material.dart';

import '../core/navigation/app_router.dart';
import '../core/network/network_aware_asset_bundle.dart';
import '../core/state/app_controller.dart';
import '../core/theme/app_theme.dart';

class MazraaApp extends StatefulWidget {
  const MazraaApp({super.key});

  @override
  State<MazraaApp> createState() => _MazraaAppState();
}

class _MazraaAppState extends State<MazraaApp> {
  final controller = AppController();
  final assetBundle = NetworkAwareAssetBundle();
  final navigatorKey = GlobalKey<NavigatorState>();
  String? _handledMessageId;

  @override
  void initState() {
    super.initState();
    controller.addListener(_handleOpenedPush);
    controller.initialize();
  }

  void _handleOpenedPush() {
    final message = controller.lastOpenedPushMessage;
    if (message == null) return;
    final id = message.messageId ?? '${message.sentTime?.millisecondsSinceEpoch}-${message.hashCode}';
    if (_handledMessageId == id) return;

    final rawRoute = '${message.data['deepLink'] ?? message.data['deep_link'] ?? message.data['route'] ?? ''}'.trim();
    _handledMessageId = id;
    controller.clearOpenedPush(message);
    if (rawRoute.isEmpty) return;

    final route = _normalizeRoute(rawRoute);
    if (route == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushNamed(route);
    });
  }

  String? _normalizeRoute(String raw) {
    if (raw.startsWith('/')) return raw;
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (uri.path.startsWith('/')) return uri.path;
    return null;
  }

  @override
  void dispose() {
    controller.removeListener(_handleOpenedPush);
    assetBundle.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
        controller: controller,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => MaterialApp(
            navigatorKey: navigatorKey,
            title: 'مزرعتي',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: controller.themeMode,
            initialRoute:
                WidgetsBinding.instance.platformDispatcher.defaultRouteName,
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) => DefaultAssetBundle(
              bundle: assetBundle,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            ),
          ),
        ),
      );
}
