import 'dart:async';

import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/view/game_view.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_burst.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_controls.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/confetti.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/board.dart';
import '../../../../helpers/game_bloc_factory.dart';

void main() {
  Future<void> pumpGame(
    WidgetTester tester, {
    GameConfig config = GameConfig.standard,
    GameBloc? bloc,
  }) async {
    final gameBloc = bloc ?? createTestGameBloc(config: config);
    addTearDown(gameBloc.close);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: BlocProvider.value(value: gameBloc, child: const GameView()),
      ),
    );
  }

  Future<void> tapSquare(WidgetTester tester, Position square) async {
    await tester.tap(find.byKey(ValueKey((square.row, square.col))));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// How big the die on [square] is drawn, from 0 to 1 of its full size.
  double dieScale(WidgetTester tester, Position square) {
    final transition = find.descendant(
      of: find.byKey(ValueKey((square.row, square.col))),
      matching: find.byType(ScaleTransition),
    );
    return tester.widget<ScaleTransition>(transition).scale.value;
  }

  /// The burst of captured dice, while one plays over the board.
  final burst = find.descendant(
    of: find.byType(CaptureBurst),
    matching: find.byType(CustomPaint),
  );

  /// The confetti, while it falls over the screen.
  final confetti = find.descendant(
    of: find.byType(Confetti),
    matching: find.byType(CustomPaint),
  );

  /// Opens the app bar's "more" menu.
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
  }

  /// The [label]ed item of the open "more" menu.
  MenuItemButton menuItem(WidgetTester tester, String label) =>
      tester.widget<MenuItemButton>(find.widgetWithText(MenuItemButton, label));

  /// Opens the "more" menu, taps its [label]ed item, and draws the frames
  /// that take, and no more: what is on the board then was drawn at once.
  /// The item acts once the frame that closes the menu is drawn, so the
  /// board shows the change on the frame after it.
  Future<void> tapMenuItemOnce(WidgetTester tester, String label) async {
    await openMenu(tester);
    await tester.tap(find.widgetWithText(MenuItemButton, label));
    await tester.pump();
    await tester.pump();
  }

  /// Opens the "more" menu, taps its [label]ed item, and lets everything
  /// settle.
  Future<void> tapMenuItem(WidgetTester tester, String label) async {
    await tapMenuItemOnce(tester, label);
    await tester.pumpAndSettle();
  }

  FilledButton captureButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  group('GameView', () {
    testWidgets('R1: shows that Player 1 moves first', (tester) async {
      await pumpGame(tester);

      expect(find.text('Player 1 to move'), findsOne);
      expect(find.byType(BoardSquare), findsNWidgets(25));
      expect(find.byType(CaptureControls), findsNothing);
    });

    testWidgets('announces the line above the board as it changes', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpGame(tester);

      expect(
        tester.getSemantics(find.text('Player 1 to move')),
        matchesSemantics(label: 'Player 1 to move', isLiveRegion: true),
      );
      semantics.dispose();
    });

    testWidgets("counts each side's dice above the board", (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpGame(tester);
      expect(
        find.bySemanticsLabel('Player 1: 0 dice. Player 2: 0 dice.'),
        findsOne,
      );

      await tapSquare(tester, const Position(2, 2));

      expect(
        find.bySemanticsLabel('Player 1: 1 die. Player 2: 0 dice.'),
        findsOne,
      );
      semantics.dispose();
    });

    testWidgets('places a die on the tapped square', (tester) async {
      await pumpGame(tester);

      await tapSquare(tester, const Position(2, 2));

      expect(diceOnBoard, findsOne);
      expect(find.text('Player 2 to move'), findsOne);
    });

    testWidgets('grows the die placed by a tap', (tester) async {
      // On the real screen, where the new die is also marked as the last
      // move: the square alone, without that mark, is not the whole story.
      await pumpGame(tester);
      const square = Position(2, 2);

      await tester.tap(find.byKey(const ValueKey((2, 2))));
      await tester.pump();
      expect(dieScale(tester, square), 0.5);

      await tester.pump(const Duration(milliseconds: 100));
      expect(dieScale(tester, square), allOf(greaterThan(0.5), lessThan(1)));

      await tester.pumpAndSettle();
      expect(dieScale(tester, square), 1);
    });

    testWidgets('takes a die back, and puts it back, at once', (tester) async {
      await pumpGame(tester);
      await tapSquare(tester, const Position(2, 2));

      await tapMenuItemOnce(tester, 'Undo');
      expect(diceOnBoard, findsNothing);

      await tapMenuItemOnce(tester, 'Redo');
      expect(dieScale(tester, const Position(2, 2)), 1);
    });

    testWidgets('takes back a move and plays it again', (tester) async {
      await pumpGame(tester);
      await tapSquare(tester, const Position(2, 2));

      await tapMenuItem(tester, 'Undo');
      expect(diceOnBoard, findsNothing);
      expect(find.text('Player 1 to move'), findsOne);

      await tapMenuItem(tester, 'Redo');
      expect(diceOnBoard, findsOne);
      expect(find.text('Player 2 to move'), findsOne);
    });

    testWidgets('has nothing to undo or redo in a new game', (tester) async {
      await pumpGame(tester);

      await openMenu(tester);

      expect(menuItem(tester, 'Undo').onPressed, isNull);
      expect(menuItem(tester, 'Redo').onPressed, isNull);
      expect(menuItem(tester, 'Restart game').onPressed, isNotNull);
    });

    group('Hint', () {
      /// The mark on the board's square at [square].
      SquareMark markAt(WidgetTester tester, Position square) {
        final squares = tester.widgetList<BoardSquare>(
          find.byType(BoardSquare),
        );
        return squares
            .firstWhere(
              (widget) =>
                  widget.square.row == square.row &&
                  widget.square.col == square.col,
            )
            .square
            .mark;
      }

      testWidgets('marks where to place a die, and says so', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpGame(tester);

        await tapMenuItem(tester, 'Hint');

        // The test agents suggest the first legal move: the top left corner.
        expect(markAt(tester, const Position(0, 0)), SquareMark.hintTarget);
        expect(
          find.bySemanticsLabel(
            'Hint: place your die at row 1, column 1. Player 1 to move',
          ),
          findsOne,
        );
        semantics.dispose();
      });

      testWidgets('clears the marks when the player places a die', (
        tester,
      ) async {
        await pumpGame(tester);
        await tapMenuItem(tester, 'Hint');

        await tapSquare(tester, const Position(2, 2));

        expect(markAt(tester, const Position(0, 0)), SquareMark.none);
      });

      testWidgets('offers no second hint while one shows', (tester) async {
        await pumpGame(tester);
        await tapMenuItem(tester, 'Hint');

        await openMenu(tester);

        expect(menuItem(tester, 'Hint').onPressed, isNull);
      });

      testWidgets('offers no hint once the game is over', (tester) async {
        await pumpGame(tester, config: const GameConfig(boardSize: 1));
        await tapSquare(tester, const Position(0, 0));

        await openMenu(tester);

        expect(menuItem(tester, 'Hint').onPressed, isNull);
      });
    });

    testWidgets('keeps only How to play and the menu in the app bar', (
      tester,
    ) async {
      await pumpGame(tester);

      final actions = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(IconButton),
      );
      expect(actions, findsNWidgets(2));
      expect(find.byTooltip('How to play'), findsOne);
      expect(find.byTooltip('More options'), findsOne);
    });

    testWidgets('R8: names the winner of a full board', (tester) async {
      await pumpGame(tester, config: const GameConfig(boardSize: 1));

      await tapSquare(tester, const Position(0, 0));

      expect(find.text('Player 1 wins 1 to 0'), findsOne);
    });

    group('at the end of a game between two people', () {
      /// Player 1 fills a one-square board, and wins.
      Future<void> win(WidgetTester tester) async {
        await pumpGame(tester, config: const GameConfig(boardSize: 1));
        await tester.tap(find.byKey(const ValueKey((0, 0))));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      testWidgets('throws confetti over the whole screen', (tester) async {
        await win(tester);

        expect(find.text('Player 1 wins 1 to 0'), findsOne);
        expect(confetti, findsOne);
        expect(
          tester.getRect(confetti),
          tester.getRect(find.byType(Scaffold)),
        );
      });

      testWidgets('lets taps through to the menu while it falls', (
        tester,
      ) async {
        await win(tester);

        await tester.tap(find.byTooltip('More options'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.widgetWithText(MenuItemButton, 'Restart game'), findsOne);
        expect(confetti, findsOne);
      });

      testWidgets('stops the confetti when the game restarts', (tester) async {
        await win(tester);

        await tapMenuItemOnce(tester, 'Restart game');

        expect(find.text('Player 1 to move'), findsOne);
        expect(confetti, findsNothing);
      });

      testWidgets('throws no confetti under less motion', (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );

        await win(tester);

        expect(find.text('Player 1 wins 1 to 0'), findsOne);
        expect(confetti, findsNothing);
      });
    });

    testWidgets('restarts the game under the same rules', (tester) async {
      await pumpGame(tester, config: const GameConfig(boardSize: 3));
      await tapSquare(tester, const Position(0, 0));

      await tapMenuItem(tester, 'Restart game');

      expect(diceOnBoard, findsNothing);
      expect(find.byType(BoardSquare), findsNWidgets(9));
      expect(find.text('Player 1 to move'), findsOne);
    });

    group('R5: with four 1s around the centre of a 3 × 3 board', () {
      /// Black and White place a 1 on each side of the centre, then Black
      /// taps the centre, where 11 captures are possible.
      Future<void> tapSurroundedCentre(WidgetTester tester) async {
        await pumpGame(tester, config: const GameConfig(boardSize: 3));
        const sides = [
          Position(0, 1),
          Position(1, 0),
          Position(1, 2),
          Position(2, 1),
        ];
        for (final square in sides) {
          await tapSquare(tester, square);
        }
        await tapSquare(tester, const Position(1, 1));
      }

      testWidgets('asks which dice to capture', (tester) async {
        await tapSurroundedCentre(tester);

        expect(find.text('Capture sum: 0 of up to 6'), findsOne);
        expect(captureButton(tester).onPressed, isNull);
      });

      testWidgets('captures the picked dice', (tester) async {
        await tapSurroundedCentre(tester);
        await tapSquare(tester, const Position(0, 1));
        await tapSquare(tester, const Position(1, 0));

        expect(find.text('Capture sum: 2 of up to 6'), findsOne);
        await tapText(tester, 'Capture');

        expect(diceOnBoard, findsNWidgets(3));
        expect(find.byType(CaptureControls), findsNothing);
        expect(find.text('Player 2 to move'), findsOne);
      });

      testWidgets('shrinks the captured dice away as the new die grows', (
        tester,
      ) async {
        const captured = [Position(0, 1), Position(1, 0)];
        await tapSurroundedCentre(tester);
        for (final square in captured) {
          await tapSquare(tester, square);
        }

        await tester.tap(find.text('Capture'));
        await tester.pump();
        // The new die and the two it captured are all still drawn.
        expect(diceOnBoard, findsNWidgets(5));
        expect(dieScale(tester, const Position(1, 1)), 0.5);
        expect(dieScale(tester, captured.first), 1);

        await tester.pump(const Duration(milliseconds: 100));
        for (final square in [const Position(1, 1), ...captured]) {
          expect(
            dieScale(tester, square),
            allOf(greaterThan(0.5), lessThan(1)),
          );
        }
        // A die that stays does not move.
        expect(dieScale(tester, const Position(1, 2)), 1);

        await tester.pumpAndSettle();
        expect(diceOnBoard, findsNWidgets(3));
        expect(dieScale(tester, const Position(1, 1)), 1);
      });

      testWidgets('bursts the captured dice while they shrink away', (
        tester,
      ) async {
        await tapSurroundedCentre(tester);
        await tapSquare(tester, const Position(0, 1));
        await tapSquare(tester, const Position(1, 0));

        await tester.tap(find.text('Capture'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(burst, findsOne);

        await tester.pumpAndSettle();
        expect(burst, findsNothing);
      });

      testWidgets('does not burst a die placed without a capture', (
        tester,
      ) async {
        await pumpGame(tester);

        await tester.tap(find.byKey(const ValueKey((2, 2))));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(burst, findsNothing);
      });

      testWidgets('takes a capture back, and plays it again, at once', (
        tester,
      ) async {
        const captured = [Position(0, 1), Position(1, 0)];
        await tapSurroundedCentre(tester);
        for (final square in captured) {
          await tapSquare(tester, square);
        }
        await tapText(tester, 'Capture');

        // Back: the new die is gone and the captured dice are whole again.
        await tapMenuItemOnce(tester, 'Undo');
        expect(diceOnBoard, findsNWidgets(4));
        expect(burst, findsNothing);
        for (final square in captured) {
          expect(dieScale(tester, square), 1);
        }

        // Again: the captured dice are gone and the new die is whole.
        await tapMenuItemOnce(tester, 'Redo');
        expect(diceOnBoard, findsNWidgets(3));
        expect(burst, findsNothing);
        expect(dieScale(tester, const Position(1, 1)), 1);
      });

      testWidgets('backs out without placing a die', (tester) async {
        await tapSurroundedCentre(tester);

        await tapText(tester, 'Cancel');

        expect(diceOnBoard, findsNWidgets(4));
        expect(find.byType(CaptureControls), findsNothing);
        expect(find.text('Player 1 to move'), findsOne);
      });
    });

    testWidgets('takes no taps while the computer thinks', (tester) async {
      final repository = InMemoryGameRepository();
      const computer = ComputerOpponent(
        difficulty: Difficulty.hard,
        player: Player.black,
      );
      await repository.save((record: GameRecord(), opponent: computer));
      final doneThinking = Completer<void>();

      // The computer chooses only once `doneThinking` completes.
      Future<R> thinkUntilDone<M, R>(
        FutureOr<R> Function(M message) callback,
        M message,
      ) async {
        await doneThinking.future;
        return callback(message);
      }

      final bloc = createTestGameBloc(
        repository: repository,
        backgroundRunner: thinkUntilDone,
      )..add(const GameResumed());
      await pumpGame(tester, bloc: bloc);
      await tester.pumpAndSettle();

      expect(find.text('The computer is thinking…'), findsOne);
      final square = tester.widget<BoardSquare>(find.byType(BoardSquare).first);
      expect(square.onTap, isNull);

      doneThinking.complete();
      await tester.pumpAndSettle();

      expect(find.text('Your turn'), findsOne);
      expect(diceOnBoard, findsOne);
    });

    group('against the computer', () {
      const oneSquare = GameConfig(boardSize: 1);

      /// Resumes a new game on a [config] board against the computer
      /// playing [player], which plays its first legal move.
      Future<void> pumpAgainst(
        WidgetTester tester,
        Player player, {
        GameConfig config = GameConfig.standard,
      }) async {
        final repository = InMemoryGameRepository();
        final computer = ComputerOpponent(
          difficulty: Difficulty.easy,
          player: player,
        );
        final record = GameRecord(config: config);
        await repository.save((record: record, opponent: computer));
        final bloc = createTestGameBloc(repository: repository)
          ..add(const GameResumed());
        await pumpGame(tester, bloc: bloc);
        await tester.pumpAndSettle();
      }

      testWidgets("says when it is the person's turn", (tester) async {
        await pumpAgainst(tester, Player.white);

        expect(find.text('Your turn'), findsOne);
      });

      testWidgets('says what the computer played, with whose turn it is', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpAgainst(tester, Player.black);

        // The computer's first legal move is the top left square.
        expect(
          tester.getSemantics(find.text('Your turn')),
          matchesSemantics(
            label: 'The computer placed a 1 at row 1, column 1. Your turn',
            isLiveRegion: true,
          ),
        );

        // The person moves and the computer replies: the line is about its
        // new move, not the old one.
        await tapSquare(tester, const Position(2, 2));
        expect(
          tester.getSemantics(find.text('Your turn')),
          matchesSemantics(
            label: 'The computer placed a 1 at row 1, column 2. Your turn',
            isLiveRegion: true,
          ),
        );
        semantics.dispose();
      });

      testWidgets('R8: says when the person won, with confetti', (
        tester,
      ) async {
        await pumpAgainst(tester, Player.white, config: oneSquare);

        await tester.tap(find.byKey(const ValueKey((0, 0))));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('You win 1 to 0'), findsOne);
        expect(confetti, findsOne);
        await tester.pumpAndSettle();
        expect(confetti, findsNothing);
      });

      testWidgets('R8: says when the computer won, without confetti', (
        tester,
      ) async {
        await pumpAgainst(tester, Player.black, config: oneSquare);

        expect(find.text('The computer wins 1 to 0'), findsOne);
        expect(confetti, findsNothing);
      });
    });
  });
}
