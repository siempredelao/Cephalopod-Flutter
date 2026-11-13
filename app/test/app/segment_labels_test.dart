import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/phone.dart';
import '../helpers/pump_app.dart';
import '../helpers/real_fonts.dart';

/// The new-game dialog's choices stay on one line each, in every language the
/// app speaks, on a small phone. A label that wraps inside a segment looks
/// broken.
///
/// Text is drawn in Roboto, the font a phone uses: the test font, Ahem, is
/// about twice as wide and would wrap labels that do not wrap on a phone.
void main() {
  setUpAll(loadRealFonts);

  /// The height of every label in the segmented buttons on screen.
  Set<double> labelHeights(WidgetTester tester) {
    final labels = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().startsWith('SegmentedButton'),
      ),
      matching: find.byType(Text),
    );
    return {
      for (final label in labels.evaluate())
        tester.getSize(find.byWidget(label.widget)).height,
    };
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('keeps each choice on one line in ${locale.languageCode}', (
      tester,
    ) async {
      final words = lookupAppLocalizations(locale);
      useSmallPhone(tester, locale);
      await pumpApp(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(words.newGameComputer));
      await tester.pumpAndSettle();

      final heights = labelHeights(tester);

      // Seven labels, and one line makes them all the same height.
      expect(find.text(words.newGameHard), findsOne);
      expect(heights, hasLength(1), reason: 'Label heights: $heights');
    });
  }
}
