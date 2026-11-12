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
        final timer = CountdownTimer();

        expect(timer.isActive, isFalse);
        await timer.done;
      },
    );

    test('is active for its duration, then done', () async {
      final waited = Stopwatch()..start();
      final timer = CountdownTimer()..start(duration);

      expect(timer.isActive, isTrue);
      await timer.done;

      expect(waited.elapsed, greaterThanOrEqualTo(duration));
      expect(timer.isActive, isFalse);
    });

    test('cancel ends it at once and lets the waiting go on', () async {
      final timer = CountdownTimer()..start(duration);
      final waiting = timer.done;

      timer.cancel();

      expect(timer.isActive, isFalse);
      await waiting;
    });

    test(
      'starting again restarts it, and releases who waited before',
      () async {
        final timer = CountdownTimer()..start(duration);
        final first = timer.done;
        await Future<void>.delayed(duration ~/ 2);

        final restarted = Stopwatch()..start();
        timer.start(duration);
        await first;

        expect(timer.isActive, isTrue);
        await timer.done;
        expect(restarted.elapsed, greaterThanOrEqualTo(duration));
      },
    );

    test('with no duration it never runs', () async {
      final timer = CountdownTimer()..start(Duration.zero);

      expect(timer.isActive, isFalse);
      await timer.done;
    });

    test('takes the length of each wait when it starts', () async {
      final timer = CountdownTimer()..start(duration);
      await timer.done;

      final waited = Stopwatch()..start();
      timer.start(duration * 2);
      await timer.done;

      expect(waited.elapsed, greaterThanOrEqualTo(duration * 2));
    });

    test('cancelling when none runs does nothing', () {
      final timer = CountdownTimer()..cancel();

      expect(timer.isActive, isFalse);
    });
  });
}
