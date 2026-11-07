import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_name.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:material_ui/material_ui.dart';

/// One [square] of the board: a dark tile or the die on it, with a glowing
/// ring around it when it has a mark. Screen readers announce where it is
/// and what is on it.
class BoardSquare extends StatelessWidget {
  const BoardSquare({required this.square, required this.onTap, super.key});

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
      label: _labelOf(square),
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

  /// "Row 2, column 3, Player 1 die showing 5", or "Row 1, column 3, empty".
  static String _labelOf(SquareUi square) {
    final where = 'Row ${square.row + 1}, column ${square.col + 1}';
    final die = square.die;
    if (die == null) return '$where, empty';
    return '$where, ${_ownerOf(die.owner)} die showing ${die.pips}';
  }

  /// Whose a die is: "Player 1" between two people, or "your" and "the
  /// computer's" against the computer.
  static String _ownerOf(SideUi side) => switch (side.role) {
    RoleUi.player => playerUiNameOf(side.player),
    RoleUi.person => 'your',
    RoleUi.computer => "the computer's",
  };

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
