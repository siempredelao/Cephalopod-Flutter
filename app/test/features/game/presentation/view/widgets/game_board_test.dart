import 'package:cephalopod/core/board/board_grid.dart';
import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/captured_die_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_burst.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// `GameBoard` is a `BoardGrid` with a `CaptureBurst` over it. What the grid
/// draws is tested with the grid.
void main() {
  /// An empty 3 × 3 board.
  final board = BoardUi(
    rows: [
      for (var row = 0; row < 3; row++)
        [
          for (var col = 0; col < 3; col++)
            SquareUi(row: row, col: col, die: null, mark: SquareMark.none),
        ],
    ],
  );

  const captured = [
    CapturedDieUi(
      row: 1,
      col: 1,
      owner: SideUi(player: PlayerUi.two, role: RoleUi.player),
    ),
  ];

  Future<void> pumpBoard(
    WidgetTester tester, {
    bool animateDice = false,
    ValueChanged<SquareUi>? onSquareTapped,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: Center(
          child: GameBoard(
            board: board,
            captured: captured,
            animateDice: animateDice,
            onSquareTapped: onSquareTapped,
          ),
        ),
      ),
    );
  }

  group('GameBoard', () {
    testWidgets('draws the board as a grid of squares', (tester) async {
      await pumpBoard(tester);

      expect(find.byType(BoardGrid), findsOne);
      expect(find.byType(BoardSquare), findsNWidgets(9));
    });

    testWidgets('bursts the captured dice over the grid', (tester) async {
      await pumpBoard(tester);

      final burst = find.descendant(
        of: find.byType(BoardGrid),
        matching: find.byType(CaptureBurst),
      );
      expect(burst, findsOne);
      expect(tester.widget<CaptureBurst>(burst).captured, captured);
      expect(tester.widget<CaptureBurst>(burst).rows, 3);
      expect(tester.widget<CaptureBurst>(burst).cols, 3);
    });

    testWidgets('lets taps through the burst to the squares', (tester) async {
      final tapped = <SquareUi>[];
      await pumpBoard(tester, onSquareTapped: tapped.add);

      await tester.tap(find.byType(BoardSquare).at(4));

      expect(tapped, [board.rows[1][1]]);
    });

    testWidgets('has the captured dice shrink one after another', (
      tester,
    ) async {
      const two = [
        CapturedDieUi(
          row: 0,
          col: 1,
          owner: SideUi(player: PlayerUi.two, role: RoleUi.player),
        ),
        CapturedDieUi(
          row: 0,
          col: 0,
          owner: SideUi(player: PlayerUi.two, role: RoleUi.player),
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(extensions: const [BoardColors.light]),
          home: Center(
            child: GameBoard(
              board: board,
              captured: two,
              onSquareTapped: null,
            ),
          ),
        ),
      );

      Duration delayAt(int row, int col) {
        final squares = tester.widgetList<BoardSquare>(
          find.byType(BoardSquare),
        );
        return squares
            .singleWhere((s) => s.square.row == row && s.square.col == col)
            .shrinkDelay;
      }

      // In the order the dice were given, not reading order: the mapper
      // sorts them, the board keeps their order.
      expect(delayAt(0, 1), Duration.zero);
      expect(delayAt(0, 0), const Duration(milliseconds: 150));
      expect(delayAt(2, 2), Duration.zero);
    });

    testWidgets('hands the dice animation on to the grid', (tester) async {
      await pumpBoard(tester, animateDice: true);

      expect(
        tester.widget<BoardGrid>(find.byType(BoardGrid)).animateDice,
        isTrue,
      );
    });
  });
}
