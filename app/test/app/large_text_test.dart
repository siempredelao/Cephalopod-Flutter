import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/phone.dart';
import '../helpers/real_fonts.dart';
import '../helpers/screens.dart';

/// Every screen at twice the text size, in both languages, on a small phone.
/// Anything that does not fit throws an overflow error.
///
/// Text is drawn in Roboto, the font a phone uses. The test font, Ahem, is
/// about twice as wide, and would report overflows that do not happen.
void main() {
  setUpAll(loadRealFonts);

  for (final locale in [const Locale('en'), const Locale('es', 'ES')]) {
    final words = lookupAppLocalizations(locale);
    group('In ${locale.languageCode}', () {
      for (final screen in screens) {
        testWidgets('${screen.name} fits at twice the text size', (
          tester,
        ) async {
          useSmallPhone(tester, locale);
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await screen.open(tester, words);

          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
