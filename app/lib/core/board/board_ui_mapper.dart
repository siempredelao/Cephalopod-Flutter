import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns an engine [Board] into the [BoardUi] a board draws: each square's
/// die and whose it is.
///
/// It knows nothing about a game. Whoever shows the board says how each
/// player appears on screen and which squares stand out.
final class BoardUiMapper {
  const BoardUiMapper();

  /// The squares of [board], with each die owned by [black] or [white] as
  /// the engine's players are. A square stands out as [marks] says, and a
  /// square [marks] leaves out does not.
  BoardUi map({
    required Board board,
    required SideUi black,
    required SideUi white,
    Map<Position, SquareMark> marks = const {},
  }) {
    SquareUi squareAt(int row, int col) {
      final position = Position(row, col);
      final die = board.dice[position];
      return SquareUi(
        row: row,
        col: col,
        die: die == null
            ? null
            : DieUi(
                pips: die.pips,
                owner: switch (die.owner) {
                  Player.black => black,
                  Player.white => white,
                },
              ),
        mark: marks[position] ?? SquareMark.none,
      );
    }

    return BoardUi(
      rows: [
        for (var row = 0; row < board.size; row++)
          [for (var col = 0; col < board.size; col++) squareAt(row, col)],
      ],
    );
  }
}
