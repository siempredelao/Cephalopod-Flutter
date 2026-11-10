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

/// The screens a player sees, each opened from a fresh app. A game is played
/// one move in, so the board holds a die and not only empty squares.
final List<Screen> screens = [
  (name: 'Home', open: (tester, _) => pumpApp(tester)),
  (
    name: 'the new-game dialog',
    open: (tester, words) async {
      await pumpApp(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // Against the computer, the dialog shows the most controls.
      await tester.tap(find.text(words.newGameComputer));
      await tester.pumpAndSettle();
    },
  ),
  (
    name: 'a game',
    open: (tester, _) async {
      await pumpApp(tester, location: '/game');
      await tester.tap(find.byKey(const ValueKey((2, 2))));
      await tester.pumpAndSettle();
    },
  ),
  (
    name: 'How to play',
    open: (tester, _) => pumpApp(tester, location: '/how-to-play'),
  ),
  (
    name: 'Settings',
    open: (tester, _) => pumpApp(tester, location: '/settings'),
  ),
  (name: 'About', open: (tester, _) => pumpApp(tester, location: '/about')),
];
