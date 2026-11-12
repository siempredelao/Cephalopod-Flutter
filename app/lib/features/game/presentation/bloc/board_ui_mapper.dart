import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/hint_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/side_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns the game on screen into the [BoardUi] the board draws: each
/// square's die, whose it is, and how the square stands out.
final class BoardUiMapper {
  const BoardUiMapper({this._sideUiMapper = const SideUiMapper()});

  final SideUiMapper _sideUiMapper;

  /// The board of [game] against [opponent], with its squares marked for
  /// [phase]: a capture's choices, or, while a die is to be placed, a hint
  /// found in it. Otherwise [lastMove] stands out when [highlightLastMove]
  /// is on.
  BoardUi map({
    required GameState game,
    required TurnPhase phase,
    required Move? lastMove,
    required Opponent opponent,
    required bool highlightLastMove,
  }) {
    final board = game.board;
    final shownLastMove = highlightLastMove ? lastMove : null;

    SquareUi squareAt(int row, int col) {
      final position = Position(row, col);
      final die = board.dice[position];
      return SquareUi(
        row: row,
        col: col,
        die: die == null ? null : _dieUiOf(die, opponent),
        mark: _markOf(position, phase, shownLastMove),
      );
    }

    return BoardUi(
      rows: [
        for (var row = 0; row < board.size; row++)
          [for (var col = 0; col < board.size; col++) squareAt(row, col)],
      ],
    );
  }

  DieUi _dieUiOf(Die die, Opponent opponent) {
    final owner = _sideUiMapper.map(die.owner, opponent);
    return DieUi(pips: die.pips, owner: owner);
  }

  /// While a capture is being chosen, the target and the dice that can be
  /// picked stand out. While a die is to be placed, a hint found in [phase]
  /// does, over the last move, since the player asked for it; or else the
  /// [lastMove], if there is one.
  SquareMark _markOf(
    Position square,
    TurnPhase phase,
    Move? lastMove,
  ) {
    return switch (phase) {
      ChoosingCapture(:final selected) when selected.contains(square) =>
        SquareMark.captureSelected,
      ChoosingCapture(:final target) when target == square =>
        SquareMark.captureTarget,
      ChoosingCapture(:final options)
          when options.any((option) => option.contains(square)) =>
        SquareMark.captureOption,
      ChoosingCapture() => SquareMark.none,
      AwaitingPlacement(hint: HintFound(:final move))
          when move.position == square =>
        SquareMark.hintTarget,
      AwaitingPlacement(hint: HintFound(:final move))
          when move.captures.contains(square) =>
        SquareMark.hintCapture,
      _ when lastMove?.position == square => SquareMark.lastMove,
      _ => SquareMark.none,
    };
  }
}
