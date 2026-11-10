import 'package:cephalopod/features/game/presentation/bloc/countdown_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Real time, so long enough that a slow machine cannot end the countdown
  // before the test has looked.
  const duration = Duration(milliseconds: 300);

  group('CountdownTimer', () {
    test(
      'is not active until it starts, and has nothing to wait for',
      () async {
        final timer = CountdownTimer(duration);

        expect(timer.isActive, isFalse);
        await timer.done;
      },
    );

    test('is active for its duration, then done', () async {
      final waited = Stopwatch()..start();
      final timer = CountdownTimer(duration)..start();

      expect(timer.isActive, isTrue);
      await timer.done;

      expect(waited.elapsed, greaterThanOrEqualTo(duration));
      expect(timer.isActive, isFalse);
    });

    test('cancel ends it at once and lets the waiting go on', () async {
      final timer = CountdownTimer(duration)..start();
      final waiting = timer.done;

      timer.cancel();

      expect(timer.isActive, isFalse);
      await waiting;
    });

    test(
      'starting again restarts it, and releases who waited before',
      () async {
        final timer = CountdownTimer(duration)..start();
        final first = timer.done;
        await Future<void>.delayed(duration ~/ 2);

        final restarted = Stopwatch()..start();
        timer.start();
        await first;

        expect(timer.isActive, isTrue);
        await timer.done;
        expect(restarted.elapsed, greaterThanOrEqualTo(duration));
      },
    );

    test('with no duration it never runs', () async {
      final timer = CountdownTimer(Duration.zero)..start();

      expect(timer.isActive, isFalse);
      await timer.done;
    });

    test('cancelling when none runs does nothing', () {
      final timer = CountdownTimer(duration)..cancel();

      expect(timer.isActive, isFalse);
    });
  });
}
