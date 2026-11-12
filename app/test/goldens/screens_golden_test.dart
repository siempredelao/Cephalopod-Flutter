import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/golden.dart';
import '../helpers/real_fonts.dart';
import '../helpers/screens.dart';

/// The main screens, drawn as images and compared pixel by pixel with the
/// ones kept in `images/`, in English and Spanish, light and dark. A change
/// to how a screen looks fails here until someone looks at it and draws the
/// images again (see the README).
///
/// Settings and About are left out: these four are the screens a player
/// spends time on, and the overflow tests already open the other two.
void main() {
  setUpAll(loadRealFonts);

  /// Each screen, by the name its images take.
  final goldenScreens = {
    'home': homeWithLessMotionScreen,
    'home_continue': homeWithSavedGameAndLessMotionScreen,
    'new_game_dialog': newGameDialogScreen,
    'game': gameScreen,
    'how_to_play': howToPlayScreen,
  };

  for (final locale in [const Locale('en'), const Locale('es', 'ES')]) {
    final words = lookupAppLocalizations(locale);
    for (final brightness in Brightness.values) {
      group('In ${locale.languageCode}, ${brightness.name}', () {
        for (final MapEntry(key: file, value: screen)
            in goldenScreens.entries) {
          testWidgets('${screen.name} looks as its image', (tester) async {
            useGoldenPhone(tester, locale, brightness);
            await screen.open(tester, words);

            await expectGolden(file, locale, brightness);
          });
        }
      });
    }
  }
}
