import 'package:cephalopod/core/board/board_ui_mapper.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = BoardUiMapper();
  const black = SideUi(player: PlayerUi.one, role: RoleUi.person);
  const white = SideUi(player: PlayerUi.two, role: RoleUi.computer);

  /// A 3 × 3 board with a black 5 at the top left and a white 2 below the
  /// centre.
  final board = stateFromAscii('''
    b5 .  .
    .  .  .
    .  w2 .
  ''', toMove: Player.black).board;

  group('BoardUiMapper', () {
    test('draws a square for each square of the board', () {
      final ui = mapper.map(board: board, black: black, white: white);

      expect(ui.rows, hasLength(3));
      expect(ui.rows, everyElement(hasLength(3)));
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 3; col++) {
          expect(ui.rows[row][col].row, row);
          expect(ui.rows[row][col].col, col);
        }
      }
    });

    test(
      "gives each die its pips and the side it was told is its player's",
      () {
        final ui = mapper.map(board: board, black: black, white: white);

        expect(ui.rows[0][0].die, const DieUi(pips: 5, owner: black));
        expect(ui.rows[2][1].die, const DieUi(pips: 2, owner: white));
        expect(ui.rows[1][1].die, isNull);
      },
    );

    test('marks the squares it is told to, and leaves the rest alone', () {
      final ui = mapper.map(
        board: board,
        black: black,
        white: white,
        marks: {
          const Position(0, 0): SquareMark.lastMove,
          const Position(1, 1): SquareMark.captureTarget,
        },
      );

      expect(ui.rows[0][0].mark, SquareMark.lastMove);
      expect(ui.rows[1][1].mark, SquareMark.captureTarget);
      expect(ui.rows[2][1].mark, SquareMark.none);
    });

    test('marks nothing without marks', () {
      final ui = mapper.map(board: board, black: black, white: white);

      expect(
        ui.rows.expand((row) => row).map((square) => square.mark),
        everyElement(SquareMark.none),
      );
    });
  });
}
