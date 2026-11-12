import 'package:cephalopod/core/board/board_grid.dart';
import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/bloc/move_timing.dart';
import 'package:cephalopod/features/game/presentation/models/captured_die_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_burst.dart';
import 'package:material_ui/material_ui.dart';

/// The [board] as a grid of [BoardSquare]s, with a [CaptureBurst] over it
/// for the dice the move just played [captured].
///
/// The captured dice shrink away one at a time, in the order of [captured],
/// each [captureStagger] after the one before.
///
/// Taps are reported, not interpreted: `GameBloc` decides what a tap on a
/// square means in the current phase.
class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.board,
    required this.onSquareTapped,
    this.animateDice = false,
    this.captured = const [],
    super.key,
  });

  final BoardUi board;

  /// Whether dice that appear or go away, now that [board] has changed, grow
  /// in and shrink away. Otherwise they are drawn at once.
  final bool animateDice;

  /// The dice the move just played captured, which burst over the board.
  final List<CapturedDieUi> captured;

  /// Told which square was tapped; `null` while the board takes no taps.
  final ValueChanged<SquareUi>? onSquareTapped;

  /// How long the die that goes away from [square] stays whole: its place
  /// among the captured dice, times [captureStagger], or nothing when it is
  /// not one of them.
  Duration _shrinkDelayOf(SquareUi square) {
    final index = captured.indexWhere(
      (die) => die.row == square.row && die.col == square.col,
    );
    return index < 0 ? Duration.zero : captureStagger * index;
  }

  @override
  Widget build(BuildContext context) {
    return BoardGrid(
      board: board,
      animateDice: animateDice,
      shrinkDelayOf: _shrinkDelayOf,
      onSquareTapped: onSquareTapped,
      overlay: CaptureBurst(
        captured: captured,
        rows: board.rows.length,
        cols: board.rows.first.length,
      ),
    );
  }
}
