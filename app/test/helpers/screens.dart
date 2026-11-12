import 'package:cephalopod/core/l10n/l10n.dart';
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

/// The home screen with the device asking for less motion, so its demo board
/// stands still on one frame, and a picture of it does not depend on when it
/// is taken.
final Screen homeWithLessMotionScreen = (
  name: 'Home, with less motion',
  open: (tester, _) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    return pumpApp(tester);
  },
);

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
  newGameDialogScreen,
  gameScreen,
  howToPlayScreen,
  settingsScreen,
  aboutScreen,
];
