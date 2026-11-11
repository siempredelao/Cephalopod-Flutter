import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/side_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/board_ui.dart';
import 'package:cephalopod/features/game/presentation/models/die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns the game on screen into the [BoardUi] the board draws: each
/// square's die, whose it is, and how the square stands out.
final class BoardUiMapper {
  const BoardUiMapper({this._sideUiMapper = const SideUiMapper()});

  final SideUiMapper _sideUiMapper;

  /// The board of [game] against [opponent], with its squares marked for
  /// [phase]. Outside a capture, a [hint] marks its square and the dice it
  /// would capture; otherwise [lastMove] stands out when
  /// [highlightLastMove] is on.
  BoardUi map({
    required GameState game,
    required TurnPhase phase,
    required Move? lastMove,
    required Opponent opponent,
    required bool highlightLastMove,
    Move? hint,
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
        mark: _markOf(position, phase, shownLastMove, hint),
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
  /// picked stand out. Otherwise a [hint] does, over the last move, since
  /// the player asked for it; or else the [lastMove], if there is one.
  SquareMark _markOf(
    Position square,
    TurnPhase phase,
    Move? lastMove,
    Move? hint,
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
      _ when hint?.position == square => SquareMark.hintTarget,
      _ when hint?.captures.contains(square) ?? false => SquareMark.hintCapture,
      _ when lastMove?.position == square => SquareMark.lastMove,
      _ => SquareMark.none,
    };
  }
}
