import 'package:cephalopod/core/board/board_thumbnail.dart';
import 'package:cephalopod/core/board/die_face.dart';
import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const player1 = SideUi(player: PlayerUi.one, role: RoleUi.player);
  const player2 = SideUi(player: PlayerUi.two, role: RoleUi.player);

  /// A 3 × 3 board with Player 1's 6 at the top left and Player 2's 2 in the
  /// middle.
  final board = BoardUi(
    rows: [
      for (var row = 0; row < 3; row++)
        [
          for (var col = 0; col < 3; col++)
            SquareUi(
              row: row,
              col: col,
              mark: SquareMark.none,
              die: switch ((row, col)) {
                (0, 0) => const DieUi(pips: 6, owner: player1),
                (1, 1) => const DieUi(pips: 2, owner: player2),
                _ => null,
              },
            ),
        ],
    ],
  );

  Future<void> pumpThumbnail(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: Center(
          child: SizedBox.square(
            dimension: 100,
            child: BoardThumbnail(board: board),
          ),
        ),
      ),
    );
  }

  /// The fill colours of the squares, in reading order.
  List<Color?> fills(WidgetTester tester) {
    final squares = find.descendant(
      of: find.byType(BoardThumbnail),
      matching: find.byType(DecoratedBox),
    );
    return [
      for (final box in tester.widgetList<DecoratedBox>(squares).skip(1))
        (box.decoration as BoxDecoration).color,
    ];
  }

  group('BoardThumbnail', () {
    testWidgets('draws a block for every square', (tester) async {
      await pumpThumbnail(tester);

      expect(fills(tester), hasLength(9));
    });

    testWidgets('colours each square by the die on it', (tester) async {
      await pumpThumbnail(tester);

      const colors = BoardColors.light;
      expect(fills(tester), [
        colors.blackDie,
        colors.square,
        colors.square,
        colors.square,
        colors.whiteDie,
        colors.square,
        colors.square,
        colors.square,
        colors.square,
      ]);
    });

    testWidgets('draws no pips', (tester) async {
      await pumpThumbnail(tester);

      expect(find.byType(DieFace), findsNothing);
    });

    testWidgets('is a square', (tester) async {
      await pumpThumbnail(tester);

      final size = tester.getSize(find.byType(BoardThumbnail));
      expect(size.width, size.height);
    });

    testWidgets('says nothing to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpThumbnail(tester);

      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      semantics.dispose();
    });
  });
}
