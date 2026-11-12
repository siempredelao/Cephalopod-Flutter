import 'dart:math' as math;

import 'package:cephalopod/features/game/presentation/view/effects/particles.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const red = Color(0xFFE53935);
  const origin = Offset(100, 100);

  /// A piece that starts at [origin] moving 40 px to the right per run.
  const piece = Particle(
    origin: origin,
    velocity: Offset(40, 0),
    color: red,
    size: Size(4, 2),
    angle: 1,
    spin: 2,
  );

  /// Where the only piece of [field] is at [progress].
  Offset positionAt(ParticleField field, double progress) {
    return field.at(progress).single.position;
  }

  group('ParticleField', () {
    test('starts every piece where it is, as it is, fully opaque', () {
      const field = ParticleField(
        particles: [piece],
        gravity: Offset(0, 50),
        drag: 3,
      );

      expect(field.at(0).single, (
        position: origin,
        angle: 1.0,
        opacity: 1.0,
        color: red,
        size: const Size(4, 2),
      ));
    });

    test('moves a piece in a straight line, at its speed, with nothing '
        'acting on it', () {
      const field = ParticleField(particles: [piece], fadeFrom: 0.5);

      expect(positionAt(field, 0.5), const Offset(120, 100));
      expect(positionAt(field, 1), const Offset(140, 100));
    });

    test('pulls a piece by gravity, more and more as the run goes on', () {
      const field = ParticleField(
        particles: [
          Particle(
            origin: origin,
            velocity: Offset.zero,
            color: red,
            size: Size(4, 2),
          ),
        ],
        gravity: Offset(0, 80),
      );

      // Half of gravity × t²: 10 px by halfway, 40 px by the end.
      expect(positionAt(field, 0.5), const Offset(100, 110));
      expect(positionAt(field, 1), const Offset(100, 140));
    });

    test('slows a piece down with drag, most of its way in the first half', () {
      const field = ParticleField(particles: [piece], drag: 4);

      final halfway = positionAt(field, 0.5).dx - origin.dx;
      final end = positionAt(field, 1).dx - origin.dx;

      // (1 - e^-4) / 4 of the 40 px it would fly without drag.
      expect(end, closeTo(40 * (1 - math.exp(-4)) / 4, 1e-9));
      expect(end, lessThan(40));
      expect(halfway, greaterThan(end - halfway));
    });

    test('lets gravity pull less with drag', () {
      const still = Particle(
        origin: origin,
        velocity: Offset.zero,
        color: red,
        size: Size(4, 2),
      );
      const withoutDrag = ParticleField(
        particles: [still],
        gravity: Offset(0, 80),
      );
      const withDrag = ParticleField(
        particles: [still],
        gravity: Offset(0, 80),
        drag: 2,
      );

      final fall = positionAt(withDrag, 1).dy - origin.dy;

      // Gravity / drag × (t - (1 - e^(-drag × t)) / drag), at t = 1.
      expect(fall, closeTo(40 * (1 - (1 - math.exp(-2)) / 2), 1e-9));
      expect(fall, lessThan(positionAt(withoutDrag, 1).dy - origin.dy));
    });

    test('turns a piece by its spin over the run', () {
      const field = ParticleField(particles: [piece]);

      expect(field.at(0.5).single.angle, 2);
      expect(field.at(1).single.angle, 3);
    });

    test('keeps pieces fully opaque until they start fading, then fades '
        'them out by the end', () {
      const field = ParticleField(particles: [piece], fadeFrom: 0.6);

      expect(field.at(0.6).single.opacity, 1);
      expect(field.at(0.8).single.opacity, closeTo(0.5, 1e-9));
      expect(field.at(1).single.opacity, 0);
    });

    test('fades pieces over the whole run by default', () {
      const field = ParticleField(particles: [piece]);

      expect(field.at(0.25).single.opacity, 0.75);
    });

    group('a piece that lives for part of the run', () {
      const late = Particle(
        origin: origin,
        velocity: Offset(40, 0),
        color: red,
        size: Size(4, 2),
        startsAt: 0.5,
      );
      const field = ParticleField(particles: [late]);

      test('is not there until it starts', () {
        expect(field.at(0.25).single.opacity, 0);
        expect(positionAt(field, 0.25), origin);
      });

      test('counts the part it lives for as its own run', () {
        // Halfway through its own run, which is the last half of the field's.
        expect(positionAt(field, 0.75), origin + const Offset(20, 0));
        expect(field.at(0.75).single.opacity, closeTo(0.5, 1e-9));
      });

      test('is faded when its run ends, before the field ends', () {
        const early = Particle(
          origin: origin,
          velocity: Offset(40, 0),
          color: red,
          size: Size(4, 2),
          endsAt: 0.5,
        );
        const earlyField = ParticleField(particles: [early]);

        expect(earlyField.at(0.5).single.opacity, 0);
        expect(positionAt(earlyField, 1), positionAt(earlyField, 0.5));
      });

      test('lets pieces in one field start one after another', () {
        const both = ParticleField(particles: [piece, late]);

        final frames = both.at(0.25);
        expect(frames[0].opacity, greaterThan(0));
        expect(frames[1].opacity, 0);
      });
    });

    test('counts moments outside the run as its start or its end', () {
      const field = ParticleField(particles: [piece]);

      expect(field.at(-1), field.at(0));
      expect(field.at(2), field.at(1));
    });
  });

  group('burstParticles', () {
    List<Particle> burst(int seed) {
      return burstParticles(
        center: origin,
        count: 12,
        speed: 50,
        pieceSize: 6,
        color: red,
        random: math.Random(seed),
      );
    }

    test('makes the pieces asked for, all from the centre, in its colour', () {
      final pieces = burst(1);

      expect(pieces, hasLength(12));
      for (final piece in pieces) {
        expect(piece.origin, origin);
        expect(piece.color, red);
      }
    });

    test('flies each piece at 60% to 100% of the speed, at 70% to 100% of '
        'the size', () {
      for (final piece in burst(2)) {
        expect(piece.velocity.distance, inInclusiveRange(30, 50));
        expect(piece.size.width, inInclusiveRange(4.2, 6));
        expect(piece.size.height, piece.size.width);
      }
    });

    test('sends one piece into each twelfth of the circle', () {
      final directions = [
        for (final piece in burst(3)) piece.velocity.direction % (2 * math.pi),
      ]..sort();
      const slice = 2 * math.pi / 12;

      for (var i = 0; i < 12; i++) {
        expect(directions[i], inInclusiveRange(i * slice, (i + 1) * slice));
      }
    });

    test('lets the pieces start and end within the run it is given', () {
      final pieces = burstParticles(
        center: origin,
        count: 4,
        speed: 10,
        pieceSize: 4,
        color: red,
        random: math.Random(1),
        startsAt: 0.2,
        endsAt: 0.8,
      );

      expect(pieces.map((piece) => piece.startsAt), everyElement(0.2));
      expect(pieces.map((piece) => piece.endsAt), everyElement(0.8));
    });

    test('gives the same burst for the same seed', () {
      expect(
        ParticleField(particles: burst(4)).at(0.5),
        ParticleField(particles: burst(4)).at(0.5),
      );
      expect(
        ParticleField(particles: burst(4)).at(0.5),
        isNot(ParticleField(particles: burst(5)).at(0.5)),
      );
    });
  });

  group('confettiParticles', () {
    const area = Size(300, 600);
    const blue = Color(0xFF1E88E5);

    List<Particle> confetti(int seed) {
      return confettiParticles(
        area: area,
        count: 30,
        pieceSize: 4,
        colors: const [red, blue],
        random: math.Random(seed),
      );
    }

    test('makes the pieces asked for, taking turns with the colours', () {
      final pieces = confetti(1);

      expect(pieces, hasLength(30));
      expect(pieces.take(4).map((piece) => piece.color), [
        red,
        blue,
        red,
        blue,
      ]);
    });

    test('starts the pieces above the area, up to half its height, across '
        'its width', () {
      for (final piece in confetti(2)) {
        expect(piece.origin.dx, inInclusiveRange(0, 300));
        expect(piece.origin.dy, inInclusiveRange(-300, 0));
      }
    });

    test('throws the pieces down, drifting a little to either side', () {
      for (final piece in confetti(3)) {
        expect(piece.velocity.dy, inInclusiveRange(120, 360));
        expect(piece.velocity.dx, inInclusiveRange(-60, 60));
      }
    });

    test('makes strips twice as wide as tall, up to half as big again', () {
      for (final piece in confetti(4)) {
        expect(piece.size.width, closeTo(2 * piece.size.height, 1e-9));
        expect(piece.size.height, inInclusiveRange(4, 6));
      }
    });

    test('gives the same confetti for the same seed', () {
      expect(
        ParticleField(particles: confetti(5)).at(0.5),
        ParticleField(particles: confetti(5)).at(0.5),
      );
      expect(
        ParticleField(particles: confetti(5)).at(0.5),
        isNot(ParticleField(particles: confetti(6)).at(0.5)),
      );
    });
  });

  group('ParticlePainter', () {
    const field = ParticleField(particles: [piece], fadeFrom: 0.5);

    Future<void> pumpPainter(WidgetTester tester, double progress) {
      return tester.pumpWidget(
        CustomPaint(
          painter: ParticlePainter(field: field, progress: progress),
          size: const Size(200, 200),
        ),
      );
    }

    testWidgets('draws each piece turned, where it is, in its colour', (
      tester,
    ) async {
      await pumpPainter(tester, 0);

      expect(
        find.byType(CustomPaint),
        paints
          ..translate(x: 100, y: 100)
          ..rotate(angle: 1)
          ..rect(rect: const Rect.fromLTWH(-2, -1, 4, 2), color: red),
      );
    });

    testWidgets('fades the pieces as the run ends', (tester) async {
      await pumpPainter(tester, 0.75);

      expect(
        find.byType(CustomPaint),
        paints..rect(color: red.withValues(alpha: 0.5)),
      );
    });

    testWidgets('draws nothing once the pieces have faded', (tester) async {
      await pumpPainter(tester, 1);

      expect(find.byType(CustomPaint), paintsNothing);
    });

    test('repaints only when the moment or the field changes', () {
      const painter = ParticlePainter(field: field, progress: 0.2);

      expect(
        painter.shouldRepaint(
          const ParticlePainter(field: field, progress: 0.2),
        ),
        isFalse,
      );
      expect(
        painter.shouldRepaint(
          const ParticlePainter(field: field, progress: 0.3),
        ),
        isTrue,
      );
      expect(
        painter.shouldRepaint(
          const ParticlePainter(
            field: ParticleField(particles: [piece]),
            progress: 0.2,
          ),
        ),
        isTrue,
      );
    });
  });
}
