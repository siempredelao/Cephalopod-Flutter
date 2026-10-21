import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/view/game_view.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_controls.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final rules = CephalopodRules();

  Future<void> pumpGame(
    WidgetTester tester, {
    GameConfig config = GameConfig.standard,
  }) async {
    final bloc = GameBloc(rules: rules, config: config);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: BlocProvider.value(value: bloc, child: const GameView()),
      ),
    );
  }

  Future<void> tapSquare(WidgetTester tester, Position square) async {
    await tester.tap(find.byKey(ValueKey(square)));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
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

    testWidgets('places a die on the tapped square', (tester) async {
      await pumpGame(tester);

      await tapSquare(tester, const Position(2, 2));

      expect(find.byType(DieFace), findsOne);
      expect(find.text('Player 2 to move'), findsOne);
    });

    testWidgets('R8: names the winner of a full board', (tester) async {
      await pumpGame(tester, config: const GameConfig(boardSize: 1));

      await tapSquare(tester, const Position(0, 0));

      expect(find.text('Player 1 wins 1 to 0'), findsOne);
    });

    testWidgets('starts a new game under the same rules', (tester) async {
      await pumpGame(tester, config: const GameConfig(boardSize: 3));
      await tapSquare(tester, const Position(0, 0));

      await tester.tap(find.byTooltip('New game'));
      await tester.pumpAndSettle();

      expect(find.byType(DieFace), findsNothing);
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

        expect(find.byType(DieFace), findsNWidgets(3));
        expect(find.byType(CaptureControls), findsNothing);
        expect(find.text('Player 2 to move'), findsOne);
      });

      testWidgets('backs out without placing a die', (tester) async {
        await tapSurroundedCentre(tester);

        await tapText(tester, 'Cancel');

        expect(find.byType(DieFace), findsNWidgets(4));
        expect(find.byType(CaptureControls), findsNothing);
        expect(find.text('Player 1 to move'), findsOne);
      });
    });
  });
}
