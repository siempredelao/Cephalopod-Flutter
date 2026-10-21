import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/view/player_name.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_mark.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:material_ui/material_ui.dart';

/// The board of the game in [state], as a square grid of [BoardSquare]s.
///
/// Taps are reported, not interpreted: `GameBloc` decides what a tap on a
/// square means in the current phase.
class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.state,
    required this.onSquareTapped,
    this.highlightLastMove = true,
    super.key,
  });

  final GameViewState state;
  final ValueChanged<Position> onSquareTapped;

  /// Whether the square of the last move stands out.
  final bool highlightLastMove;

  static const double _gap = 2;
  static const double _cornerRadius = 16;
  static const double _edgeWidth = 2;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    final board = state.game.board;
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.board,
          borderRadius: BorderRadius.circular(_cornerRadius),
          border: Border.all(color: colors.boardEdge, width: _edgeWidth),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_gap / 2),
          child: Column(
            children: [
              for (var row = 0; row < board.size; row++)
                Expanded(
                  child: Row(
                    // Each square takes the row's full height; centred, an
                    // empty one would shrink to its padding.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < board.size; col++)
                        Expanded(child: _square(Position(row, col), board)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _square(Position square, Board board) {
    final die = board.dice[square];
    return Padding(
      padding: const EdgeInsets.all(_gap / 2),
      child: BoardSquare(
        key: ValueKey(square),
        die: die,
        mark: _markOf(square),
        label: _labelOf(square, die),
        onTap: () => onSquareTapped(square),
      ),
    );
  }

  /// While a capture is being chosen, the target and the dice that can be
  /// picked stand out; otherwise the last move does, unless
  /// [highlightLastMove] is off.
  SquareMark _markOf(Position square) => switch (state.phase) {
    ChoosingCapture(:final selected) when selected.contains(square) =>
      SquareMark.captureSelected,
    ChoosingCapture(:final target) when target == square =>
      SquareMark.captureTarget,
    ChoosingCapture(:final options)
        when options.any((option) => option.contains(square)) =>
      SquareMark.captureOption,
    ChoosingCapture() => SquareMark.none,
    _ when highlightLastMove && state.lastMove?.position == square =>
      SquareMark.lastMove,
    _ => SquareMark.none,
  };

  static String _labelOf(Position square, Die? die) {
    final where = 'Row ${square.row + 1}, column ${square.col + 1}';
    return die == null
        ? '$where, empty'
        : '$where, ${playerNameOf(die.owner)} die showing ${die.pips}';
  }
}
