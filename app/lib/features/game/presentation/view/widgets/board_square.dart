import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_mark.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:material_ui/material_ui.dart';

/// One square of the board: empty or holding a [die], outlined by its
/// [mark]. Screen readers announce it as [label].
class BoardSquare extends StatelessWidget {
  const BoardSquare({
    required this.die,
    required this.mark,
    required this.label,
    required this.onTap,
    super.key,
  });

  final Die? die;
  final SquareMark mark;
  final String label;
  final VoidCallback onTap;

  static const double _markWidth = 3;
  static const double _dieInset = 6;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    final die = this.die;
    final markColor = switch (mark) {
      SquareMark.none => null,
      SquareMark.lastMove => colors.lastMove,
      SquareMark.captureTarget => colors.captureTarget,
      SquareMark.captureOption => colors.captureOption,
      SquareMark.captureSelected => colors.captureSelected,
    };
    return Semantics(
      label: label,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.square,
            border: markColor == null
                ? null
                : Border.all(color: markColor, width: _markWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_dieInset),
            child: die == null ? null : DieFace(die: die),
          ),
        ),
      ),
    );
  }
}
