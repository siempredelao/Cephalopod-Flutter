import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const player1 = SideUi(player: PlayerUi.one, role: RoleUi.player);
  const player2 = SideUi(player: PlayerUi.two, role: RoleUi.player);

  /// A 5 × 5 board with [dice] on their (row, column) squares, and the
  /// squares in [marks] standing out.
  BoardUi boardOf(
    Map<(int, int), DieUi> dice, {
    Map<(int, int), SquareMark> marks = const {},
  }) {
    SquareUi squareAt(int row, int col) {
      return SquareUi(
        row: row,
        col: col,
        die: dice[(row, col)],
        mark: marks[(row, col)] ?? SquareMark.none,
      );
    }

    return BoardUi(
      rows: [
        for (var row = 0; row < 5; row++)
          [for (var col = 0; col < 5; col++) squareAt(row, col)],
      ],
    );
  }

  /// Rule sheet Fig. 4: the 1s of Player 2 either side of the top centre
  /// square, and the 5 of Player 1 below it.
  final figure4 = boardOf({
    (0, 1): const DieUi(pips: 1, owner: player2),
    (0, 3): const DieUi(pips: 1, owner: player2),
    (1, 2): const DieUi(pips: 5, owner: player1),
  });

  Future<void> pumpBoard(
    WidgetTester tester,
    BoardUi board, {
    ValueChanged<SquareUi>? onSquareTapped,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: Center(
          child: GameBoard(board: board, onSquareTapped: onSquareTapped),
        ),
      ),
    );
  }

  BoardSquare squareAt(WidgetTester tester, int row, int col) =>
      tester.widget<BoardSquare>(find.byKey(ValueKey((row, col))));

  group('GameBoard', () {
    testWidgets('shows one square per board square', (tester) async {
      await pumpBoard(tester, figure4);

      expect(find.byType(BoardSquare), findsNWidgets(25));
    });

    testWidgets('draws empty and full squares as squares', (tester) async {
      await pumpBoard(tester, figure4);

      for (final square in [(0, 2), (1, 2), (4, 4)]) {
        final size = tester.getSize(find.byKey(ValueKey(square)));
        expect(size.height, moreOrLessEquals(size.width, epsilon: 0.01));
        expect(size.width, greaterThan(100));
      }
    });

    testWidgets('shows each die on its square', (tester) async {
      await pumpBoard(tester, figure4);

      expect(find.byType(DieFace), findsNWidgets(3));
      expect(squareAt(tester, 1, 2).square.die?.pips, 5);
      expect(squareAt(tester, 0, 2).square.die, isNull);
    });

    testWidgets('names each square for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpBoard(tester, figure4);

      expect(
        find.bySemanticsLabel('Row 1, column 2, Player 2 die showing 1'),
        findsOne,
      );
      expect(
        find.bySemanticsLabel('Row 2, column 3, Player 1 die showing 5'),
        findsOne,
      );
      expect(find.bySemanticsLabel('Row 1, column 3, empty'), findsOne);
      semantics.dispose();
    });

    testWidgets("names the dice yours or the computer's", (tester) async {
      final semantics = tester.ensureSemantics();
      final board = boardOf({
        (0, 1): const DieUi(
          pips: 1,
          owner: SideUi(player: PlayerUi.two, role: RoleUi.computer),
        ),
        (1, 2): const DieUi(
          pips: 5,
          owner: SideUi(player: PlayerUi.one, role: RoleUi.person),
        ),
      });

      await pumpBoard(tester, board);

      expect(
        find.bySemanticsLabel("Row 1, column 2, the computer's die showing 1"),
        findsOne,
      );
      expect(
        find.bySemanticsLabel('Row 2, column 3, your die showing 5'),
        findsOne,
      );
      semantics.dispose();
    });

    testWidgets('reports the tapped square', (tester) async {
      final tapped = <SquareUi>[];
      await pumpBoard(tester, figure4, onSquareTapped: tapped.add);

      await tester.tap(find.byKey(const ValueKey((0, 2))));

      expect(tapped, [squareAt(tester, 0, 2).square]);
    });

    testWidgets('takes no taps without a handler', (tester) async {
      await pumpBoard(tester, figure4);

      expect(squareAt(tester, 0, 2).onTap, isNull);
    });

    testWidgets("shows each square's mark", (tester) async {
      final board = boardOf(
        {(1, 2): const DieUi(pips: 5, owner: player1)},
        marks: {
          (0, 2): SquareMark.captureTarget,
          (1, 2): SquareMark.captureOption,
        },
      );

      await pumpBoard(tester, board);

      expect(squareAt(tester, 0, 2).square.mark, SquareMark.captureTarget);
      expect(squareAt(tester, 1, 2).square.mark, SquareMark.captureOption);
      expect(squareAt(tester, 4, 4).square.mark, SquareMark.none);
    });
  });
}
