import 'package:cephalopod/core/board/board_grid.dart';
import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/models/captured_die_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_burst.dart';
import 'package:material_ui/material_ui.dart';

/// The [board] as a grid of [BoardSquare]s, with a [CaptureBurst] over it
/// for the dice the move just played [captured].
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

  @override
  Widget build(BuildContext context) {
    return BoardGrid(
      board: board,
      animateDice: animateDice,
      onSquareTapped: onSquareTapped,
      overlay: CaptureBurst(
        captured: captured,
        rows: board.rows.length,
        cols: board.rows.first.length,
      ),
    );
  }
}
