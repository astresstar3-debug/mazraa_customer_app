import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mazraa_customer_app/app/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MazraaApp());
    await tester.pump();
  }

  testWidgets('تعرض الصفحة الرئيسية أقسام السوق والمزادات', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    expect(find.text('المزادات الحية'), findsOneWidget);
    expect(find.text('العروض المميزة'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('يعمل الانتقال إلى الأقسام والسلة', (tester) async {
    await pumpApp(tester, const Size(430, 932));
    await tester.tap(find.text('الأقسام').last);
    await tester.pumpAndSettle();
    expect(find.text('مستلزمات النحل'), findsOneWidget);
    await tester.tap(find.text('سلة التسوق').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('سلة التسوق'), findsWidgets);
  });
}
