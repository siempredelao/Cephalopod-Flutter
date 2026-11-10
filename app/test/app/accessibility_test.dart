import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/phone.dart';
import '../helpers/screens.dart';

/// Flutter's accessibility guidelines on every screen, in both languages.
///
/// Text is drawn in the test font, Ahem, on purpose. The contrast guideline
/// reads colours from a screenshot, and a real font's soft edges make it
/// report dark text on a light background as too faint. Ahem's solid letters
/// give the colours the theme chose. `large_text_test.dart` uses a real font,
/// because it needs real widths.
void main() {
  for (final locale in [const Locale('en'), const Locale('es', 'ES')]) {
    final words = lookupAppLocalizations(locale);
    group('In ${locale.languageCode}', () {
      for (final screen in screens) {
        testWidgets('${screen.name} meets the accessibility guidelines', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          useSmallPhone(tester, locale);
          await screen.open(tester, words);

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          semantics.dispose();
        });
      }
    });
  }
}
