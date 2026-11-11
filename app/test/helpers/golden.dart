import 'package:cephalopod/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'phone.dart';

/// Shows the test as its golden image does: on a small phone, whose language
/// is [locale] and whose system theme is [brightness]. The app follows the
/// system theme, its default setting. The test puts the phone back when it
/// ends.
///
/// Text needs `loadRealFonts` in `setUpAll`, so the image shows real words.
void useGoldenPhone(
  WidgetTester tester,
  Locale locale,
  Brightness brightness,
) {
  useSmallPhone(tester, locale);
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
}

/// Checks the app on screen against its golden image, kept next to the test
/// in `images/<screen>_<language>_<brightness>.png`, such as
/// `images/home_en_light.png`.
///
/// `flutter test --update-goldens` draws the images again (see the README).
Future<void> expectGolden(
  String screen,
  Locale locale,
  Brightness brightness,
) {
  return expectLater(
    find.byType(App),
    matchesGoldenFile(
      'images/${screen}_${locale.languageCode}_${brightness.name}.png',
    ),
  );
}
