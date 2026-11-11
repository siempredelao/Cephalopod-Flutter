import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// One small piece that flies across the screen in an effect, such as the
/// burst of a captured die or the confetti for a win.
///
/// Distances are in logical pixels. Time is measured in runs of the effect:
/// 0 is its start and 1 its end, however long it lasts on screen. So
/// [velocity] is how far the piece would fly in the whole run with nothing
/// slowing it down, and [spin] is how far it turns in that run.
final class Particle {
  const Particle({
    required this.origin,
    required this.velocity,
    required this.color,
    required this.size,
    this.angle = 0,
    this.spin = 0,
  });

  /// Where the piece's centre starts.
  final Offset origin;

  /// Which way, and how fast, the piece starts to move.
  final Offset velocity;

  final Color color;

  /// The piece is a rectangle of this size.
  final Size size;

  /// How far the piece is turned at the start, in radians.
  final double angle;

  /// How far the piece turns during the run, in radians.
  final double spin;
}

/// Where a [Particle] is, and how it looks, at one moment of its effect.
typedef ParticleFrame = ({
  Offset position,
  double angle,
  double opacity,
  Color color,
  Size size,
});

/// A set of [particles] that move together under the same [gravity] and
/// [drag], and fade out together at the end of the run.
///
/// [at] works out every piece at a moment of the run, so an effect only
/// needs the moment: an animation's value from 0 to 1.
final class ParticleField {
  const ParticleField({
    required this.particles,
    this.gravity = Offset.zero,
    this.drag = 0,
    this.fadeFrom = 0,
  }) : assert(drag >= 0, 'Drag slows pieces down, so it is not negative.'),
       assert(
         fadeFrom >= 0 && fadeFrom < 1,
         'Pieces start fading at a moment of the run, before its end.',
       );

  final List<Particle> particles;

  /// How much every piece's speed changes over the run: positive y pulls
  /// pieces down the screen.
  final Offset gravity;

  /// How strongly the air slows the pieces: 0 lets them keep their speed,
  /// and a piece with a drag of 4 has lost about 98% of its starting speed
  /// by the end of the run.
  final double drag;

  /// The moment of the run, from 0 to 1, at which the pieces start to fade.
  /// They are fully faded at 1. With 0, they fade for the whole run.
  final double fadeFrom;

  /// Every piece at [progress], a moment of the run from 0 (its start) to 1
  /// (its end). Moments outside the run count as its start or end.
  List<ParticleFrame> at(double progress) {
    final t = progress.clamp(0.0, 1.0);
    // How far a piece has moved along its starting velocity, and how far
    // gravity has pulled it, at t. With drag k, a piece's speed falls by
    // e^(-kt), so both distances come out shorter than without air.
    final double alongVelocity;
    final double byGravity;
    if (drag == 0) {
      alongVelocity = t;
      byGravity = t * t / 2;
    } else {
      alongVelocity = (1 - math.exp(-drag * t)) / drag;
      byGravity = (t - alongVelocity) / drag;
    }
    final opacity = _opacityAt(t);

    return [
      for (final particle in particles)
        (
          position:
              particle.origin +
              particle.velocity * alongVelocity +
              gravity * byGravity,
          angle: particle.angle + particle.spin * t,
          opacity: opacity,
          color: particle.color,
          size: particle.size,
        ),
    ];
  }

  /// How opaque the pieces are at [t]: fully until [fadeFrom], then less
  /// and less, until they are gone at the end.
  double _opacityAt(double t) {
    if (t <= fadeFrom) {
      return 1;
    }
    return 1 - (t - fadeFrom) / (1 - fadeFrom);
  }
}

/// [count] pieces of [color] that fly out of [center] in every direction,
/// as from something bursting.
///
/// The pieces are spread evenly around the circle, each turned a little off
/// its place, so the burst looks random but leaves no side empty. Each one
/// flies between 60% and 100% of [speed], and is between 70% and 100% of
/// [pieceSize] wide. [random] decides all of this, so the same seed gives
/// the same burst every time.
List<Particle> burstParticles({
  required Offset center,
  required int count,
  required double speed,
  required double pieceSize,
  required Color color,
  required math.Random random,
}) {
  final slice = 2 * math.pi / count;
  return [
    for (var i = 0; i < count; i++)
      Particle(
        origin: center,
        velocity: Offset.fromDirection(
          (i + random.nextDouble()) * slice,
          speed * _between(0.6, 1, random),
        ),
        color: color,
        size: Size.square(pieceSize * _between(0.7, 1, random)),
        angle: random.nextDouble() * math.pi,
        spin: _between(-2, 2, random) * math.pi,
      ),
  ];
}

/// A random number from [low] up to [high].
double _between(double low, double high, math.Random random) {
  return low + (high - low) * random.nextDouble();
}

/// Draws a [field] at [progress], a moment of its run from 0 to 1. Each
/// piece is a rectangle, turned by its angle, in its colour, faded by how
/// far the run has gone. A fully faded piece is not drawn.
///
/// It repaints only when the moment or the field changes.
class ParticlePainter extends CustomPainter {
  const ParticlePainter({required this.field, required this.progress});

  final ParticleField field;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in field.at(progress)) {
      if (piece.opacity <= 0) {
        continue;
      }
      paint.color = piece.color.withValues(
        alpha: piece.color.a * piece.opacity,
      );
      canvas
        ..save()
        ..translate(piece.position.dx, piece.position.dy)
        ..rotate(piece.angle)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size.width,
            height: piece.size.height,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.field != field;
  }
}
