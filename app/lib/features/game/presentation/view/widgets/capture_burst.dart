import 'dart:math' as math;

import 'package:cephalopod/core/board/board_durations.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/captured_die_ui.dart';
import 'package:cephalopod/features/game/presentation/view/effects/particles.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';

/// The burst of each die the move just played [captured], drawn over a
/// board of [rows] by [cols] equal squares that fills this widget.
///
/// From each captured square, a ring flashes outward and pieces in the
/// die's colours fly out, fall a little and fade. The pieces may cross the
/// squares around it, so the burst is one layer over the whole board, not a
/// part of each square. It lasts as long as the die shrinking away under
/// it, so the board has stopped moving when the next move can start.
///
/// It plays when [captured] changes to dice the move captured, once. There
/// is none when the device asks for less motion, and a burst still playing
/// stops at once when [captured] empties, as after an undo.
class CaptureBurst extends StatefulWidget {
  const CaptureBurst({
    required this.captured,
    required this.rows,
    required this.cols,
    super.key,
  });

  final List<CapturedDieUi> captured;
  final int rows;
  final int cols;

  /// How long a burst lasts.
  static const Duration duration = dieAnimationDuration;

  @override
  State<CaptureBurst> createState() => _CaptureBurstState();
}

class _CaptureBurstState extends State<CaptureBurst>
    with SingleTickerProviderStateMixin {
  /// Pieces per captured die, half in its face colour and half in the
  /// colour of its edge, which shows on a board close to the face colour.
  static const int _piecesPerColor = 6;

  // Sizes and speeds as fractions of a square's side.
  static const double _speed = 2.2;
  static const double _pieceSize = 0.16;
  static const double _gravity = 1.5;
  static const double _drag = 2;

  /// The moment of the burst, from 0 to 1, at which its pieces start to
  /// fade.
  static const double _fadeFrom = 0.35;

  /// How far through the burst it is, from 0 to 1.
  late final AnimationController _run = AnimationController(
    vsync: this,
    duration: CaptureBurst.duration,
  );

  /// The pieces of the burst playing, and what they were made for, so they
  /// are made once per burst, not on every frame.
  ({Size size, List<CapturedDieUi> captured, BoardColors colors})? _madeFor;
  ParticleField _field = const ParticleField(particles: []);

  @override
  void didUpdateWidget(CaptureBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.captured, widget.captured)) {
      return;
    }
    if (widget.captured.isEmpty || MediaQuery.disableAnimationsOf(context)) {
      _run.reset();
    } else {
      _run.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: _run,
        builder: (context, _) {
          if (!_run.isAnimating) {
            return const SizedBox.expand();
          }
          final size = constraints.biggest;
          return CustomPaint(
            size: size,
            painter: _FlashPainter(
              flashes: _flashesIn(size, colors),
              squareSide: _squareSideIn(size),
              progress: _run.value,
            ),
            foregroundPainter: ParticlePainter(
              field: _fieldFor(size, colors),
              progress: _run.value,
            ),
          );
        },
      ),
    );
  }

  /// The pieces for the dice captured, on a board of [size], made again
  /// only when the dice, the size or the colours change.
  ParticleField _fieldFor(Size size, BoardColors colors) {
    final key = (size: size, captured: widget.captured, colors: colors);
    if (key == _madeFor) {
      return _field;
    }
    final side = _squareSideIn(size);
    // The same dice always burst the same way, so the burst can be tested.
    final random = math.Random(_seedOf(widget.captured));
    _madeFor = key;
    return _field = ParticleField(
      gravity: Offset(0, side * _gravity),
      drag: _drag,
      fadeFrom: _fadeFrom,
      particles: [
        for (final die in widget.captured)
          for (final color in _colorsOf(die, colors))
            ...burstParticles(
              center: _centerOf(die, size),
              count: _piecesPerColor,
              speed: side * _speed,
              pieceSize: side * _pieceSize,
              color: color,
              random: random,
            ),
      ],
    );
  }

  /// Where each captured square's ring flashes, and in which colour.
  List<({Offset center, Color color})> _flashesIn(
    Size size,
    BoardColors colors,
  ) {
    return [
      for (final die in widget.captured)
        (center: _centerOf(die, size), color: _colorsOf(die, colors).last),
    ];
  }

  /// The face colour and the edge colour of [die], in that order.
  static List<Color> _colorsOf(CapturedDieUi die, BoardColors colors) {
    return switch (die.owner.player) {
      PlayerUi.one => [colors.blackDie, colors.blackDieEdge],
      PlayerUi.two => [colors.whiteDie, colors.whiteDieEdge],
    };
  }

  Offset _centerOf(CapturedDieUi die, Size size) {
    return Offset(
      (die.col + 0.5) * size.width / widget.cols,
      (die.row + 0.5) * size.height / widget.rows,
    );
  }

  double _squareSideIn(Size size) {
    return math.min(size.width / widget.cols, size.height / widget.rows);
  }

  /// A number that depends only on the squares captured. Not `hashCode`,
  /// which can change from one run of the app to the next.
  static int _seedOf(List<CapturedDieUi> captured) {
    return captured.fold(0, (seed, die) => seed * 31 + die.row * 16 + die.col);
  }
}

/// A ring that flashes outward from each captured square at the start of a
/// burst, and is gone by the time its pieces start to fade.
class _FlashPainter extends CustomPainter {
  const _FlashPainter({
    required this.flashes,
    required this.squareSide,
    required this.progress,
  });

  final List<({Offset center, Color color})> flashes;
  final double squareSide;
  final double progress;

  /// The moment of the burst, from 0 to 1, at which the flash is gone.
  static const double _end = 0.35;

  // Sizes as fractions of a square's side.
  static const double _startRadius = 0.25;
  static const double _endRadius = 0.6;
  static const double _strokeWidth = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= _end) {
      return;
    }
    final t = progress / _end;
    final radius =
        squareSide * (_startRadius + (_endRadius - _startRadius) * t);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = squareSide * _strokeWidth * (1 - t);
    for (final flash in flashes) {
      paint.color = flash.color.withValues(alpha: 1 - t);
      canvas.drawCircle(flash.center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_FlashPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.squareSide != squareSide ||
        !listEquals(oldDelegate.flashes, flashes);
  }
}
