import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/board_ui.dart';
import 'package:cephalopod/features/game/presentation/models/captured_die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_burst.dart';
import 'package:material_ui/material_ui.dart';

/// The [board] as a square grid of [BoardSquare]s, with a [CaptureBurst]
/// over it for the dice the move just played [captured].
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

  static const double _gap = 2;
  static const double _cornerRadius = 16;
  static const double _edgeWidth = 2;

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
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
          child: Stack(
            children: [
              Column(
                children: [
                  for (final row in board.rows)
                    Expanded(
                      child: Row(
                        // Each square takes the row's full height; centred,
                        // an empty one would shrink to its padding.
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final square in row)
                            Expanded(child: _tile(square)),
                        ],
                      ),
                    ),
                ],
              ),
              // Over the squares, and letting taps through to them.
              Positioned.fill(
                child: IgnorePointer(
                  child: CaptureBurst(
                    captured: captured,
                    rows: board.rows.length,
                    cols: board.rows.first.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(SquareUi square) {
    final onSquareTapped = this.onSquareTapped;
    return Padding(
      padding: const EdgeInsets.all(_gap / 2),
      child: BoardSquare(
        key: ValueKey((square.row, square.col)),
        square: square,
        animateDie: animateDice,
        onTap: onSquareTapped == null ? null : () => onSquareTapped(square),
      ),
    );
  }
}
