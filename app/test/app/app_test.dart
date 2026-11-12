import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/new_game_dialog.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:cephalopod/features/how_to_play/presentation/view/how_to_play_page.dart';
import 'package:cephalopod/features/settings/presentation/view/settings_page.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/board.dart';
import '../helpers/fake_sound_effects.dart';
import '../helpers/pump_app.dart';

void main() {
  /// From home, opens the new-game dialog and starts a game against a
  /// friend.
  Future<void> startNewGame(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'New game'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pumpAndSettle();
  }

  /// The opponent the game on screen was started against.
  Opponent? opponentOnScreen(WidgetTester tester) {
    final opening = tester.widget<GamePage>(find.byType(GamePage)).opening;
    return opening is GameStarted ? opening.opponent : null;
  }

  group('App', () {
    testWidgets('starts on the home page', (tester) async {
      await pumpApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('opens How to play over Home on a first launch', (
      tester,
    ) async {
      await pumpApp(tester, firstLaunch: true);

      expect(find.byType(HowToPlayPage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(HowToPlayPage), findsNothing);
    });

    testWidgets('opens How to play by itself only once', (tester) async {
      await pumpApp(tester, firstLaunch: true);
      await tester.tap(find.widgetWithText(TextButton, 'Skip'));
      await tester.pumpAndSettle();

      // Back from a game, Home asks again whether there is one to continue,
      // but not about How to play.
      await startNewGame(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(HowToPlayPage), findsNothing);
    });

    testWidgets('speaks Spanish on a Spanish device', (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('es', 'ES')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpApp(tester);

      expect(find.text('Nueva partida'), findsOneWidget);
    });

    testWidgets('speaks English on a device in any other language', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = [const Locale('fr', 'FR')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpApp(tester);

      expect(find.text('New game'), findsOneWidget);
    });

    testWidgets('opens a new game against a friend from home', (tester) async {
      await pumpApp(tester);

      await startNewGame(tester);

      expect(find.byType(NewGameDialog), findsNothing);
      expect(opponentOnScreen(tester), const FriendOpponent());
    });

    testWidgets('opens a new game against the computer', (tester) async {
      // Hard, with the person moving first and the computer playing White.
      const computer = ComputerOpponent(
        difficulty: Difficulty.hard,
        player: Player.white,
      );
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'New game'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('The computer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await tester.pumpAndSettle();

      expect(opponentOnScreen(tester), computer);
    });

    testWidgets('stays home when the new-game dialog is cancelled', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'New game'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(NewGameDialog), findsNothing);
      expect(find.byType(GamePage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('offers to continue a game left unfinished', (tester) async {
      await pumpApp(tester);
      expect(find.text('Continue'), findsNothing);

      await startNewGame(tester);
      await tester.tap(find.byType(BoardSquare).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(GamePage), findsOneWidget);
      expect(diceOnBoard, findsOneWidget);
    });

    testWidgets('opens a game against the opponent a link names', (
      tester,
    ) async {
      const computer = ComputerOpponent(
        difficulty: Difficulty.hard,
        player: Player.white,
      );

      await pumpApp(tester, location: '/game?computer=white&difficulty=hard');

      expect(opponentOnScreen(tester), computer);
    });

    testWidgets('goes back home from a deep link to a game', (tester) async {
      await pumpApp(tester, location: '/game');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(GamePage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('opens how to play from home', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'How to play'));
      await tester.pumpAndSettle();

      expect(find.byType(HowToPlayPage), findsOneWidget);
    });

    testWidgets('opens how to play from a game and returns to it', (
      tester,
    ) async {
      await pumpApp(tester, location: '/game');
      await tester.tap(find.byType(BoardSquare).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('How to play'));
      await tester.pumpAndSettle();
      expect(find.byType(HowToPlayPage), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(HowToPlayPage), findsNothing);
      expect(diceOnBoard, findsOneWidget);
    });

    testWidgets('switches to the dark theme from the settings', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      ThemeMode themeMode() {
        return tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
      }

      expect(themeMode(), ThemeMode.dark);
      // The settings page's cubit closes on the way back; the theme stays.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsNothing);
      expect(themeMode(), ThemeMode.dark);
    });

    testWidgets('opens games with the highlight the settings chose', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Settings'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Highlight the last move'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await startNewGame(tester);
      await tester.tap(find.byKey(const ValueKey((2, 2))));
      await tester.pumpAndSettle();

      final squares = tester.widgetList<BoardSquare>(find.byType(BoardSquare));
      expect(diceOnBoard, findsOne);
      expect(
        squares.map((square) => square.square.mark),
        everyElement(SquareMark.none),
      );
    });

    group('in a game against a friend', () {
      /// Player 1 and Player 2 place a 1 each, beside the top left corner,
      /// and Player 1 captures both from the corner.
      Future<void> captureInTheCorner(WidgetTester tester) async {
        await startNewGame(tester);
        for (final square in const [(0, 1), (1, 0), (0, 0)]) {
          await tester.tap(find.byKey(ValueKey(square)));
          await tester.pumpAndSettle();
        }
        expect(diceOnBoard, findsOne);
      }

      testWidgets('pops when dice are captured', (tester) async {
        final sounds = FakeSoundEffects();
        await pumpApp(tester, soundEffects: sounds);

        await captureInTheCorner(tester);

        expect(sounds.played, ['capture']);
      });

      testWidgets('keeps quiet when the settings turn sound off', (
        tester,
      ) async {
        final sounds = FakeSoundEffects();
        await pumpApp(tester, soundEffects: sounds);
        await tester.tap(find.widgetWithText(OutlinedButton, 'Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SwitchListTile, 'Sound'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        await captureInTheCorner(tester);

        expect(sounds.played, isEmpty);
      });
    });

    testWidgets('opens the about page from home', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'About'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutPage), findsOneWidget);
    });

    testWidgets('goes back home from a deep link to about', (tester) async {
      await pumpApp(tester, location: '/about');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(AboutPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('credits Mark Steere on the about page', (tester) async {
      await pumpApp(tester, location: '/about');

      expect(
        find.text('Cephalopod was designed by Mark Steere.'),
        findsOneWidget,
      );
    });

    testWidgets('shows the debug banner in the dev flavor', (tester) async {
      await pumpApp(tester, flavor: Flavor.dev);

      expect(find.byType(CheckedModeBanner), findsOneWidget);
    });

    testWidgets('hides the debug banner in the prod flavor', (tester) async {
      await pumpApp(tester);

      expect(find.byType(CheckedModeBanner), findsNothing);
    });
  });
}
