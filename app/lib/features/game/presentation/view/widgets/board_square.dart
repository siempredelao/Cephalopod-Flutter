import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/game_durations.dart';
import 'package:cephalopod/features/game/presentation/view/square_text_mapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_ring.dart';
import 'package:material_ui/material_ui.dart';

/// One [square] of the board: a tile or the die on it, with a glowing ring
/// around it when it has a mark. Screen readers announce where it is and what
/// is on it.
///
/// With [animateDie], a die that appears grows into the square and a die
/// that goes away shrinks out of it, unless the device asks for less motion.
/// Without it, and for a die already there when the square first shows, the
/// change is drawn at once.
class BoardSquare extends StatefulWidget {
  const BoardSquare({
    required this.square,
    required this.onTap,
    this.animateDie = false,
    this._squareTextMapper = const SquareTextMapper(),
    super.key,
  });

  final SquareTextMapper _squareTextMapper;

  final SquareUi square;

  /// Whether the die that appears or goes away, now that [square] has
  /// changed, grows in or shrinks away.
  final bool animateDie;

  /// Called when the square is tapped; `null` when it takes no taps.
  final VoidCallback? onTap;

  @override
  State<BoardSquare> createState() => _BoardSquareState();
}

class _BoardSquareState extends State<BoardSquare>
    with SingleTickerProviderStateMixin {
  /// The size a die grows from and shrinks to, as a fraction of its full
  /// size.
  static const double _smallestDie = 0.5;

  /// How much of the die is there, from 0, none of it, to 1, all of it.
  /// Growing runs it up and shrinking runs it down.
  late final AnimationController _presence;

  /// [_presence] slowing down as the die reaches its full size.
  late final CurvedAnimation _opacity;
  late final Animation<double> _scale;

  /// The die drawn on the tile: the square's own, or the one that was on it
  /// and is still shrinking away.
  DieUi? _drawnDie;

  @override
  void initState() {
    super.initState();
    _drawnDie = widget.square.die;
    _presence = AnimationController(
      vsync: this,
      duration: dieAnimationDuration,
      value: _drawnDie == null ? 0 : 1,
    );
    _opacity = CurvedAnimation(parent: _presence, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: _smallestDie, end: 1).animate(_opacity);
  }

  @override
  void didUpdateWidget(BoardSquare oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.square.die;
    final now = widget.square.die;
    if (now == before) return;

    final animate =
        widget.animateDie && !MediaQuery.disableAnimationsOf(context);
    if (now == null) {
      if (animate) {
        // The die stays drawn while it shrinks.
        _presence.reverse();
      } else {
        _drawnDie = null;
        _presence.value = 0;
      }
    } else {
      _drawnDie = now;
      if (before == null && animate) {
        _presence.forward(from: 0);
      } else {
        _presence.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    _presence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final square = widget.square;
    final onTap = widget.onTap;
    final die = _drawnDie;
    return Semantics(
      label: widget._squareTextMapper.map(square, context.l10n),
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SquareRing(
          mark: square.mark,
          // The tile stays under the die, so the die grows out of the
          // square it is placed on, and shrinks back into it.
          child: DecoratedBox(
            decoration: _tileOf(colors.square),
            child: AnimatedBuilder(
              animation: _presence,
              // Built here, not on every frame of the animation.
              child: die == null ? null : DieFace(die: die),
              builder: (context, dieFace) {
                // No die, or one that has finished shrinking away.
                if (dieFace == null || _presence.isDismissed) {
                  return const SizedBox.expand();
                }
                return FadeTransition(
                  opacity: _opacity,
                  child: ScaleTransition(scale: _scale, child: dieFace),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static BoxDecoration _tileOf(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(SquareRing.tileCornerRadius),
    );
  }
}
