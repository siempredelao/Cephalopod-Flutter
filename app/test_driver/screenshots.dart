import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Runs on the computer that started `flutter drive`: saves each screenshot
/// the test takes as `art/play-store/<name>.png`, where the name the test
/// gives includes the language's folder.
Future<void> main() {
  return integrationDriver(
    onScreenshot: (name, image, [args]) async {
      final file = File('../art/play-store/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(image);
      return true;
    },
  );
}
