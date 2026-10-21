import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_mark.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const top = Position(0, 2);
  const left = Position(0, 1);
  const right = Position(0, 3);
  const below = Position(1, 2);

  /// Rule sheet Fig. 4: a die on the top centre square can capture with the
  /// 1s either side and the 5 below.
  final figure4 = stateFromAscii('''
    .  w1 .  w1 .
    .  .  b5 .  .
    .  .  .  .  .
    .  .  .  .  .
    .  .  .  .  .
  ''', toMove: Player.black);

  GameViewState placing({Move? lastMove}) => GameViewState(
    game: figure4,
    phase: const TurnPhase.awaitingPlacement(),
    lastMove: lastMove,
  );

  Future<void> pumpBoard(
    WidgetTester tester,
    GameViewState state, {
    ValueChanged<Position>? onSquareTapped,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: Center(
          child: GameBoard(
            state: state,
            onSquareTapped: onSquareTapped ?? (_) {},
          ),
        ),
      ),
    );
  }

  BoardSquare squareAt(WidgetTester tester, Position position) =>
      tester.widget<BoardSquare>(find.byKey(ValueKey(position)));

  group('GameBoard', () {
    testWidgets('shows one square per board square', (tester) async {
      await pumpBoard(tester, placing());

      expect(find.byType(BoardSquare), findsNWidgets(25));
    });

    testWidgets('draws empty and full squares as squares', (tester) async {
      await pumpBoard(tester, placing());

      for (final position in [top, below, const Position(4, 4)]) {
        final size = tester.getSize(find.byKey(ValueKey(position)));
        expect(size.height, moreOrLessEquals(size.width, epsilon: 0.01));
        expect(size.width, greaterThan(100));
      }
    });

    testWidgets('shows each die on its square', (tester) async {
      await pumpBoard(tester, placing());

      expect(find.byType(DieFace), findsNWidgets(3));
      expect(squareAt(tester, below).die, figure4.board.dice[below]);
      expect(squareAt(tester, top).die, isNull);
    });

    testWidgets('names each square for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpBoard(tester, placing());

      expect(find.bySemanticsLabel('Row 1, column 2, white 1'), findsOne);
      expect(find.bySemanticsLabel('Row 2, column 3, black 5'), findsOne);
      expect(find.bySemanticsLabel('Row 1, column 3, empty'), findsOne);
      semantics.dispose();
    });

    testWidgets('reports the tapped square', (tester) async {
      final tapped = <Position>[];
      await pumpBoard(tester, placing(), onSquareTapped: tapped.add);

      await tester.tap(find.byKey(const ValueKey(top)));

      expect(tapped, [top]);
    });

    testWidgets('marks the last move', (tester) async {
      await pumpBoard(tester, placing(lastMove: Move(below)));

      expect(squareAt(tester, below).mark, SquareMark.lastMove);
      expect(squareAt(tester, top).mark, SquareMark.none);
    });

    testWidgets('R5: marks the target and the pickable dice', (tester) async {
      final choosing = placing(lastMove: Move(below)).copyWith(
        phase: TurnPhase.choosingCapture(
          target: top,
          options: [
            {left, right},
            {left, below},
            {right, below},
          ],
          selected: {left},
        ),
      );

      await pumpBoard(tester, choosing);

      expect(squareAt(tester, top).mark, SquareMark.captureTarget);
      expect(squareAt(tester, left).mark, SquareMark.captureSelected);
      expect(squareAt(tester, right).mark, SquareMark.captureOption);
      expect(squareAt(tester, below).mark, SquareMark.captureOption);
      expect(squareAt(tester, const Position(4, 4)).mark, SquareMark.none);
    });
  });
}
