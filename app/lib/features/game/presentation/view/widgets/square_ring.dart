import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:material_ui/material_ui.dart';

/// The glowing ring around a square's tile ([child]) that shows its
/// [mark]: the last move, or a capture's target, options and choices. The
/// colour comes from the board's palette. With no mark, there is no ring,
/// but its room stays, so the tile is the same size either way.
class SquareRing extends StatelessWidget {
  const SquareRing({required this.mark, required this.child, super.key});

  final SquareMark mark;

  /// The tile, inside the ring.
  final Widget child;

  static const double _ringWidth = 3;
  static const double _ringGlow = 8;
  static const double _glowOpacity = 0.4;

  /// The tile's corner radius, which the ring follows from outside.
  static const double tileCornerRadius = 10;

  /// Room for the ring, so the tile is the same size whether marked or not.
  static const double _ringInset = 6;

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final color = switch (mark) {
      SquareMark.none => null,
      SquareMark.lastMove => colors.lastMove,
      SquareMark.captureTarget => colors.captureTarget,
      SquareMark.captureOption => colors.captureOption,
      SquareMark.captureSelected => colors.captureSelected,
    };
    // The ring's box is there even without a ring. A box that came and went
    // with the mark would make Flutter build everything inside it again, and
    // a die in the tile would lose its place in its animation.
    return DecoratedBox(
      decoration: _ringOf(color),
      child: Padding(
        padding: const EdgeInsets.all(_ringInset),
        child: child,
      ),
    );
  }

  /// A glowing ring in [color] around the tile, or nothing drawn without a
  /// colour.
  static BoxDecoration _ringOf(Color? color) {
    if (color == null) return const BoxDecoration();
    return BoxDecoration(
      borderRadius: BorderRadius.circular(tileCornerRadius + _ringInset),
      border: Border.all(color: color, width: _ringWidth),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: _glowOpacity),
          blurRadius: _ringGlow,
        ),
      ],
    );
  }
}
