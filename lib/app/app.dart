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

  @override
  void initState() {
    super.initState();
    controller.initialize();
  }

  @override
  void dispose() {
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
