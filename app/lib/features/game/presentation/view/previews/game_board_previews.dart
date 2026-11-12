import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/previews/board_preview_wrapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

const SideUi _player1 = SideUi(player: PlayerUi.one, role: RoleUi.player);
const SideUi _player2 = SideUi(player: PlayerUi.two, role: RoleUi.player);

@Preview(
  group: 'GameBoard',
  name: 'New game',
  size: Size(400, 400),
  wrapper: boardPreviewWrapper,
)
Widget newGamePreview() => _boardOf({});

@Preview(
  group: 'GameBoard',
  name: 'Mid-game, last move marked',
  size: Size(400, 400),
  wrapper: boardPreviewWrapper,
)
Widget midGamePreview() {
  return _boardOf(
    {
      (0, 0): const DieUi(pips: 1, owner: _player2),
      (0, 2): const DieUi(pips: 2, owner: _player1),
      (1, 1): const DieUi(pips: 1, owner: _player1),
      (2, 0): const DieUi(pips: 6, owner: _player1),
      (2, 2): const DieUi(pips: 5, owner: _player2),
      (3, 2): const DieUi(pips: 4, owner: _player1),
      (4, 1): const DieUi(pips: 5, owner: _player2),
    },
    marks: {(2, 2): SquareMark.lastMove},
  );
}

/// Rule sheet Fig. 4: a die on the top centre square can capture three ways.
/// Player 1 has picked the 1 on the left.
@Preview(
  group: 'GameBoard',
  name: 'Choosing a capture (R5)',
  size: Size(400, 400),
  wrapper: boardPreviewWrapper,
)
Widget choosingCapturePreview() {
  return _boardOf(
    {
      (0, 1): const DieUi(pips: 1, owner: _player2),
      (0, 3): const DieUi(pips: 1, owner: _player2),
      (1, 2): const DieUi(pips: 5, owner: _player1),
    },
    marks: {
      (0, 2): SquareMark.captureTarget,
      (0, 1): SquareMark.captureSelected,
      (0, 3): SquareMark.captureOption,
      (1, 2): SquareMark.captureOption,
    },
  );
}

/// A standard 5 × 5 board with [dice] on their (row, column) squares, and
/// the squares in [marks] standing out.
Widget _boardOf(
  Map<(int, int), DieUi> dice, {
  Map<(int, int), SquareMark> marks = const {},
}) {
  const size = 5;
  SquareUi squareAt(int row, int col) {
    return SquareUi(
      row: row,
      col: col,
      die: dice[(row, col)],
      mark: marks[(row, col)] ?? SquareMark.none,
    );
  }

  final board = BoardUi(
    rows: [
      for (var row = 0; row < size; row++)
        [for (var col = 0; col < size; col++) squareAt(row, col)],
    ],
  );
  return GameBoard(board: board, onSquareTapped: (_) {});
}
