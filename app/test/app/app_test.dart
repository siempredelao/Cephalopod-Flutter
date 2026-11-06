import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod/features/about/about_module.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/game_module.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/how_to_play_page.dart';
import 'package:cephalopod/features/game/presentation/view/new_game_page.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/home/home_module.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:cephalopod/features/settings/presentation/view/settings_page.dart';
import 'package:cephalopod/features/settings/settings_module.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Flavor flavor = Flavor.prod,
    String location = '/',
  }) async {
    // Wired as bootstrap wires it, with storage in memory.
    final settings = SettingsModule(
      settingsRepository: InMemorySettingsRepository(),
    );
    addTearDown(settings.cubit.close);
    final game = GameModule(
      cephalopodRules: CephalopodRules(),
      gameRepository: InMemoryGameRepository(),
      highlightLastMove: settings.highlightLastMove,
    );
    final router = createRouter(
      home: HomeModule(hasGameToContinue: game.hasGameToContinue),
      features: [game, settings, const AboutModule()],
      initialLocation: location,
    );
    await tester.pumpWidget(
      App(flavor: flavor, router: router, settings: settings.cubit),
    );
    await tester.pumpAndSettle();
  }

  /// From home, opens the new-game screen and starts a game against a
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

    testWidgets('opens a new game against a friend from home', (tester) async {
      await pumpApp(tester);

      await startNewGame(tester);

      expect(find.byType(GamePage), findsOneWidget);
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

    testWidgets('comes back to the new-game screen after a game', (
      tester,
    ) async {
      await pumpApp(tester);
      await startNewGame(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(NewGamePage), findsOneWidget);
    });

    testWidgets('offers to continue a game left unfinished', (tester) async {
      await pumpApp(tester);
      expect(find.text('Continue'), findsNothing);

      await startNewGame(tester);
      await tester.tap(find.byType(BoardSquare).first);
      await tester.pumpAndSettle();
      // Back from the game, then from the new-game screen.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(GamePage), findsOneWidget);
      expect(find.byType(DieFace), findsOneWidget);
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
      expect(find.byType(DieFace), findsOneWidget);
    });

    testWidgets('switches to the dark theme from the settings', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('opens games with the highlight the settings chose', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await startNewGame(tester);

      final page = tester.widget<GamePage>(find.byType(GamePage));
      expect(page.highlightLastMove, isFalse);
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

      expect(find.textContaining('Mark Steere'), findsOneWidget);
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
