import 'dart:math' as math;

import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/effects/particles.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';

/// Confetti that falls over all the space it is given, for a win.
///
/// It falls once, for [duration], when [play] turns on, in the dice's coral
/// and cream and the theme's colours. It stops at once when [play] turns
/// off, as when a new game starts, and does not fall when the device asks
/// for less motion. It does not take taps itself; whoever puts it over the
/// screen keeps taps going through it.
class Confetti extends StatefulWidget {
  const Confetti({required this.play, super.key});

  /// Whether the screen celebrates a win.
  final bool play;

  /// How long the confetti takes to fall.
  static const Duration duration = Duration(seconds: 3);

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  static const int _pieces = 150;
  static const double _pieceSize = 6;

  /// How strongly the air slows the pieces, so they float down rather than
  /// drop.
  static const double _drag = 1.5;

  /// How hard the pieces fall, in screen heights per run, so even those
  /// that start highest come well into the screen.
  static const double _gravity = 3;

  /// The moment of the fall, from 0 to 1, at which the pieces start to fade.
  static const double _fadeFrom = 0.75;

  /// Every win throws the same confetti, so it can be tested.
  static const int _seed = 7;

  late final AnimationController _fall = AnimationController(
    vsync: this,
    duration: Confetti.duration,
  );

  /// The confetti falling, and what it was made for, so it is made once
  /// per fall, not on every frame.
  ({Size size, List<Color> colors})? _madeFor;
  ParticleField _field = const ParticleField(particles: []);

  @override
  void didUpdateWidget(Confetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.play == widget.play) {
      return;
    }
    if (widget.play && !MediaQuery.disableAnimationsOf(context)) {
      _fall.forward(from: 0);
    } else {
      _fall.reset();
    }
  }

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: _fall,
        builder: (context, _) {
          if (!_fall.isAnimating) {
            return const SizedBox.expand();
          }
          final size = constraints.biggest;
          return CustomPaint(
            size: size,
            painter: ParticlePainter(
              field: _fieldFor(size, colors),
              progress: _fall.value,
            ),
          );
        },
      ),
    );
  }

  /// The confetti's colours: the dice's, the last move's ring and a hint's,
  /// and the theme's own.
  static List<Color> _colorsOf(BuildContext context) {
    final board = BoardColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return [
      board.blackDie,
      board.whiteDie,
      board.lastMove,
      board.hintTarget,
      scheme.primary,
      scheme.tertiary,
    ];
  }

  /// The confetti for a screen of [size], made again only when the size or
  /// the colours change.
  ParticleField _fieldFor(Size size, List<Color> colors) {
    // Colours compared one by one, as a new list is made on every build.
    final madeFor = _madeFor;
    if (madeFor != null &&
        madeFor.size == size &&
        listEquals(madeFor.colors, colors)) {
      return _field;
    }
    _madeFor = (size: size, colors: colors);
    return _field = ParticleField(
      gravity: Offset(0, size.height * _gravity),
      drag: _drag,
      fadeFrom: _fadeFrom,
      particles: confettiParticles(
        area: size,
        count: _pieces,
        pieceSize: _pieceSize,
        colors: colors,
        random: math.Random(_seed),
      ),
    );
  }
}
