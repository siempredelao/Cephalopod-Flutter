import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// A small phone, in logical pixels.
const Size smallPhone = Size(360, 800);

/// Shows the test on a [smallPhone] whose language is [locale]. The test puts
/// both back when it ends.
void usePhone(WidgetTester tester, Locale locale) {
  tester.view
    ..physicalSize = smallPhone
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}
