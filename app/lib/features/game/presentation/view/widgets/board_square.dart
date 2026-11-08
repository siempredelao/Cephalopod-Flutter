import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/square_text_mapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:material_ui/material_ui.dart';

/// One [square] of the board: a dark tile or the die on it, with a glowing
/// ring around it when it has a mark. Screen readers announce where it is
/// and what is on it.
class BoardSquare extends StatelessWidget {
  const BoardSquare({
    required this.square,
    required this.onTap,
    this._squareTextMapper = const SquareTextMapper(),
    super.key,
  });

  final SquareTextMapper _squareTextMapper;

  final SquareUi square;

  /// Called when the square is tapped; `null` when it takes no taps.
  final VoidCallback? onTap;

  static const double _ringWidth = 3;
  static const double _ringGlow = 8;
  static const double _glowOpacity = 0.4;
  static const double _cornerRadius = 10;

  /// Room for the ring, so the tile is the same size whether marked or not.
  static const double _ringInset = 6;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    final die = square.die;
    final markColor = switch (square.mark) {
      SquareMark.none => null,
      SquareMark.lastMove => colors.lastMove,
      SquareMark.captureTarget => colors.captureTarget,
      SquareMark.captureOption => colors.captureOption,
      SquareMark.captureSelected => colors.captureSelected,
    };
    return Semantics(
      label: _squareTextMapper.map(square),
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: _ringOf(markColor),
          padding: const EdgeInsets.all(_ringInset),
          child: die == null
              ? DecoratedBox(decoration: _tileOf(colors.square))
              : DieFace(die: die),
        ),
      ),
    );
  }

  /// A glowing ring in [color] around the tile, or none without a colour.
  static BoxDecoration? _ringOf(Color? color) {
    if (color == null) return null;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_cornerRadius + _ringInset),
      border: Border.all(color: color, width: _ringWidth),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: _glowOpacity),
          blurRadius: _ringGlow,
        ),
      ],
    );
  }

  static BoxDecoration _tileOf(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(_cornerRadius),
    );
  }
}
