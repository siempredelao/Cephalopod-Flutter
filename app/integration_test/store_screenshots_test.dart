import 'package:cephalopod/app/bootstrap.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/l10n/generated/app_localizations.dart';
import 'package:cephalopod/features/home/presentation/view/widgets/continue_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language to take the screenshots in, such as `es`. The phone's own
/// language stays as it is: the test only tells the app to use another.
const _language = String.fromEnvironment('LANGUAGE', defaultValue: 'en');

/// The squares played, counted left to right and top to bottom from 0 to 24.
/// The last square, 17, has three neighbours that can be captured in
/// different ways, so the game waits for the person to choose.
const _moves = [6, 8, 7, 12, 18, 16, 17];

/// The dice chosen for the capture, which the game shows as selected.
const _captured = [12, 16, 18];

/// Takes the Play Store screenshots, in one language, on a device. Run it
/// with `tool/take_store_screenshots.sh`, which runs it once per language
/// and saves the images in `art/play-store/<language>/`.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('takes the store screenshots in $_language', (tester) async {
    final l10n = lookupAppLocalizations(const Locale(_language));
    tester.platformDispatcher.localesTestValue = [const Locale(_language)];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await SharedPreferencesAsync().clear();
    bootstrap(Flavor.prod);
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();

    // A capture's effects keep the frames coming, so `pumpAndSettle` would
    // wait for them for ever. Waiting a fixed time works everywhere.
    Future<void> wait() => tester.pump(const Duration(seconds: 1));

    Future<void> shoot(String name) async {
      await wait();
      await binding.takeScreenshot('$_language/$name');
    }

    Future<void> tapText(String text) async {
      await tester.tap(find.text(text));
      await wait();
    }

    Future<void> tapSquares(List<int> squares) async {
      for (final square in squares) {
        await tester.tap(find.byType(BoardSquare).at(square));
        await wait();
      }
    }

    // A first launch opens How to play.
    await shoot('1-how-to-play');
    await tapText(l10n.howToPlaySkip);
    await shoot('2-home');

    // The new-game dialog, with the computer chosen.
    await tapText(l10n.homeNewGame);
    await tapText(l10n.newGameComputer);
    await tapText(l10n.newGameHard);
    await shoot('3-new-game');

    // A game against a friend, played to a capture to choose.
    await tapText(l10n.newGameFriend);
    await tapText(l10n.newGameStart);
    await tapSquares(_moves);
    await tapSquares(_captured);
    await shoot('4-game');

    // The same game in the dark theme.
    await tester.tap(find.byType(BackButton));
    await wait();
    await tapText(l10n.homeSettings);
    await tapText(l10n.settingsThemeDark);
    await tester.tap(find.byType(BackButton));
    await wait();
    await tester.tap(find.byType(ContinueCard));
    await wait();
    await shoot('5-game-dark');
  });
}
