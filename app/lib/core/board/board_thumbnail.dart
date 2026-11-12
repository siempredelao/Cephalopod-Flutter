import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The [board] drawn small, to recognise a game by: each square is a block of
/// colour, the colour of the die on it or the plain square if it has none.
/// There are no pips, because at this size the gaps between the squares hide
/// them and a die's number could not be read.
///
/// It is a picture only. It takes no taps and says nothing to screen
/// readers, so whoever shows it describes the game in words.
class BoardThumbnail extends StatelessWidget {
  const BoardThumbnail({required this.board, super.key});

  final BoardUi board;

  static const double _gap = 1.5;
  static const double _cornerRadius = 8;
  static const double _squareRadius = 3;

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.board,
            borderRadius: BorderRadius.circular(_cornerRadius),
            border: Border.all(color: colors.boardEdge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_gap / 2),
            child: Column(
              children: [
                for (final row in board.rows)
                  Expanded(
                    child: Row(
                      children: [
                        for (final square in row)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(_gap / 2),
                              child: _Square(die: square.die, colors: colors),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({required this.die, required this.colors});

  final DieUi? die;
  final BoardColors colors;

  @override
  Widget build(BuildContext context) {
    final die = this.die;
    final (fill, edge) = switch (die?.owner.player) {
      null => (colors.square, null),
      PlayerUi.one => (colors.blackDie, colors.blackDieEdge),
      PlayerUi.two => (colors.whiteDie, colors.whiteDieEdge),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(BoardThumbnail._squareRadius),
        border: edge == null ? null : Border.all(color: edge),
      ),
      child: const SizedBox.expand(),
    );
  }
}
