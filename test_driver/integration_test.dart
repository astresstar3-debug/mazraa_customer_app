import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    writeResponseOnFailure: true,
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('screenshots/$screenshotName.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(screenshotBytes, flush: true);
      return screenshotBytes.isNotEmpty;
    },
  );
}
