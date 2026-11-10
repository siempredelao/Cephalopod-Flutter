import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/square_text_mapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:material_ui/material_ui.dart';

/// One [square] of the board: a tile or the die on it, with a glowing ring
/// around it when it has a mark. Screen readers announce where it is and what
/// is on it.
///
/// A die that appears on a square grows into it, unless the device asks for
/// less motion. A die that goes away, and a die already there when the
/// square first shows, are drawn at once.
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

  /// How long a new die takes to grow into its square: long enough to see,
  /// short enough that the next move is not kept waiting.
  static const Duration _growDuration = Duration(milliseconds: 200);

  /// The size a die starts growing from, as a fraction of its full size.
  static const double _growFrom = 0.5;

  static const Key _emptyKey = ValueKey('empty');
  static const Key _dieKey = ValueKey('die');

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final die = square.die;
    final markColor = switch (square.mark) {
      SquareMark.none => null,
      SquareMark.lastMove => colors.lastMove,
      SquareMark.captureTarget => colors.captureTarget,
      SquareMark.captureOption => colors.captureOption,
      SquareMark.captureSelected => colors.captureSelected,
    };
    return Semantics(
      label: _squareTextMapper.map(square, context.l10n),
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
          // The tile stays under the die, so the die grows out of the square
          // it is placed on.
          child: DecoratedBox(
            decoration: _tileOf(colors.square),
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : _growDuration,
              // A die that goes away does so at once; capturing has its own
              // animation.
              reverseDuration: Duration.zero,
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: _grow,
              layoutBuilder: _fill,
              child: die == null
                  ? const SizedBox.expand(key: _emptyKey)
                  : DieFace(key: _dieKey, die: die),
            ),
          ),
        ),
      ),
    );
  }

  /// Fades and scales a die in as it appears.
  static Widget _grow(Widget child, Animation<double> animation) {
    if (child.key != _dieKey) return child;
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: _growFrom, end: 1).animate(animation),
        child: child,
      ),
    );
  }

  /// Stacks the old and the new child, each filling the square.
  static Widget _fill(Widget? current, List<Widget> previous) {
    return Stack(
      fit: StackFit.expand,
      children: [...previous, ?current],
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
