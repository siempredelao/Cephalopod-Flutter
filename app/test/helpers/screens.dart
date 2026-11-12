import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';

/// How a screen is reached, given the app's words in the language on screen,
/// and what to call it in a test's name.
typedef Screen = ({
  String name,
  Future<void> Function(WidgetTester tester, AppLocalizations words) open,
});

/// The home screen.
final Screen homeScreen = (name: 'Home', open: (tester, _) => pumpApp(tester));

/// The home screen with a game saved: a game against the computer on the Hard
/// level, four moves in, with the person to move.
final Screen homeWithSavedGameScreen = (
  name: 'Home, with a saved game',
  open: (tester, _) => pumpApp(tester, savedGame: _savedGame),
);

/// The saved game of [homeWithSavedGameScreen]: black, the person, plays the
/// middle and a far corner, and the computer, white, two other corners.
final SavedGame _savedGame = (
  record: GameRecord(
    moves: [
      Move(const Position(2, 2)),
      Move(const Position(0, 0)),
      Move(const Position(4, 4)),
      Move(const Position(0, 4)),
    ],
  ),
  opponent: const ComputerOpponent(
    difficulty: Difficulty.hard,
    player: Player.white,
  ),
);

/// The home screen with the device asking for less motion, so its demo board
/// stands still on one frame, and a picture of it does not depend on when it
/// is taken.
final Screen homeWithLessMotionScreen = (
  name: 'Home, with less motion',
  open: (tester, _) {
    _askForLessMotion(tester);
    return pumpApp(tester);
  },
);

/// [homeWithSavedGameScreen] with the device asking for less motion, for the
/// same reason as [homeWithLessMotionScreen].
final Screen homeWithSavedGameAndLessMotionScreen = (
  name: 'Home, with a saved game and less motion',
  open: (tester, _) {
    _askForLessMotion(tester);
    return pumpApp(tester, savedGame: _savedGame);
  },
);

void _askForLessMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

/// The new-game dialog, against the computer, where it shows the most
/// controls.
final Screen newGameDialogScreen = (
  name: 'the new-game dialog',
  open: (tester, words) async {
    await pumpApp(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(words.newGameComputer));
    await tester.pumpAndSettle();
  },
);

/// A game one move in, so the board holds a die and not only empty squares.
final Screen gameScreen = (
  name: 'a game',
  open: (tester, _) async {
    await pumpApp(tester, location: '/game');
    await tester.tap(find.byKey(const ValueKey((2, 2))));
    await tester.pumpAndSettle();
  },
);

/// How to play.
final Screen howToPlayScreen = (
  name: 'How to play',
  open: (tester, _) => pumpApp(tester, location: '/how-to-play'),
);

/// The settings.
final Screen settingsScreen = (
  name: 'Settings',
  open: (tester, _) => pumpApp(tester, location: '/settings'),
);

/// About.
final Screen aboutScreen = (
  name: 'About',
  open: (tester, _) => pumpApp(tester, location: '/about'),
);

/// The screens a player sees, each opened from a fresh app.
final List<Screen> screens = [
  homeScreen,
  homeWithSavedGameScreen,
  newGameDialogScreen,
  gameScreen,
  howToPlayScreen,
  settingsScreen,
  aboutScreen,
];
