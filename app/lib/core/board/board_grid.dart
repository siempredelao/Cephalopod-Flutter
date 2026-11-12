import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The [board] as a square grid of [BoardSquare]s.
///
/// Taps are reported, not interpreted: whoever shows the grid decides what a
/// tap on a square means.
class BoardGrid extends StatelessWidget {
  const BoardGrid({
    required this.board,
    required this.onSquareTapped,
    this.animateDice = false,
    this.shrinkDelayOf = _noDelay,
    this.overlay,
    super.key,
  });

  final BoardUi board;

  /// Whether dice that appear or go away, now that [board] has changed, grow
  /// in and shrink away. Otherwise they are drawn at once.
  final bool animateDice;

  /// How long the die that goes away from a square stays whole before it
  /// shrinks, so dice taken together can go one after another. None by
  /// default.
  final Duration Function(SquareUi square) shrinkDelayOf;

  /// Drawn over the squares, filling the grid inside its edge. Taps go
  /// through it to the squares.
  final Widget? overlay;

  /// Told which square was tapped; `null` while the board takes no taps.
  final ValueChanged<SquareUi>? onSquareTapped;

  static Duration _noDelay(SquareUi square) => Duration.zero;

  static const double _gap = 2;
  static const double _cornerRadius = 16;
  static const double _edgeWidth = 2;

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final overlay = this.overlay;
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
              if (overlay != null)
                Positioned.fill(child: IgnorePointer(child: overlay)),
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
        shrinkDelay: shrinkDelayOf(square),
        onTap: onSquareTapped == null ? null : () => onSquareTapped(square),
      ),
    );
  }
}
