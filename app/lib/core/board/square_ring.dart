import 'dart:math' as math;

import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The glowing ring around a square's tile ([child]) that shows its
/// [mark]: the last move, a capture's target, options and choices, or a
/// hint. The colour comes from the board's palette. With no mark, there is
/// no ring, but its room stays, so the tile is the same size either way.
///
/// A hint's square pulses: its glow swells and settles a few times as it
/// appears, then holds still, so it catches the eye without nagging. It
/// does not pulse when the device asks for less motion.
class SquareRing extends StatefulWidget {
  const SquareRing({required this.mark, required this.child, super.key});

  final SquareMark mark;

  /// The tile, inside the ring.
  final Widget child;

  /// The tile's corner radius, which the ring follows from outside.
  static const double tileCornerRadius = 10;

  /// How long a hint's square pulses, all its pulses together.
  static const Duration pulseDuration = Duration(milliseconds: 1800);

  @override
  State<SquareRing> createState() => _SquareRingState();
}

class _SquareRingState extends State<SquareRing>
    with SingleTickerProviderStateMixin {
  static const double _ringWidth = 3;
  static const double _ringGlow = 8;
  static const double _glowOpacity = 0.4;

  /// Room for the ring, so the tile is the same size whether marked or not.
  static const double _ringInset = 6;

  /// How many times a hint's glow swells and settles.
  static const int _pulses = 3;

  /// How far through its pulses a hint's ring is, from 0 to 1. At rest, at
  /// either end, the ring glows as any other.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: SquareRing.pulseDuration,
  );

  /// Whether the ring has pulsed for the hint it shows, so a theme or text
  /// size change does not start it again.
  bool _pulsed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _followMark();
  }

  @override
  void didUpdateWidget(SquareRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _followMark();
  }

  /// Pulses once when the mark becomes a hint's square, and stops when it
  /// no longer is one, or the device asks for less motion.
  void _followMark() {
    if (widget.mark != SquareMark.hintTarget) {
      _pulsed = false;
      _pulse.value = 0;
    } else if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.value = 0;
    } else if (!_pulsed) {
      _pulsed = true;
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final color = switch (widget.mark) {
      SquareMark.none => null,
      SquareMark.lastMove => colors.lastMove,
      SquareMark.captureTarget => colors.captureTarget,
      SquareMark.captureOption => colors.captureOption,
      SquareMark.captureSelected => colors.captureSelected,
      SquareMark.hintTarget => colors.hintTarget,
      SquareMark.hintCapture => colors.hintCapture,
    };
    // The ring's box is there even without a ring. A box that came and went
    // with the mark would make Flutter build everything inside it again, and
    // a die in the tile would lose its place in its animation. The pulse
    // only redraws the box; the tile is built once, outside it.
    return AnimatedBuilder(
      animation: _pulse,
      child: Padding(
        padding: const EdgeInsets.all(_ringInset),
        child: widget.child,
      ),
      builder: (context, tile) => DecoratedBox(
        decoration: _ringOf(color, swell: _swellAt(_pulse.value)),
        child: tile,
      ),
    );
  }

  /// How swollen the glow is, from 0, at rest, to 1, at the top of a pulse,
  /// [progress] of the way through the pulses.
  static double _swellAt(double progress) {
    return (1 - math.cos(2 * math.pi * _pulses * progress)) / 2;
  }

  /// A glowing ring in [color] around the tile, or nothing drawn without a
  /// colour. A [swell] above 0 widens and brightens the glow.
  static BoxDecoration _ringOf(Color? color, {required double swell}) {
    if (color == null) return const BoxDecoration();
    return BoxDecoration(
      borderRadius: BorderRadius.circular(
        SquareRing.tileCornerRadius + _ringInset,
      ),
      border: Border.all(color: color, width: _ringWidth),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: _glowOpacity + 0.5 * swell),
          blurRadius: _ringGlow * (1 + 1.5 * swell),
          spreadRadius: 2 * swell,
        ),
      ],
    );
  }
}
