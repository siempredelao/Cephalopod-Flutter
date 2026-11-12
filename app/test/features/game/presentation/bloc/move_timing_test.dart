import 'package:cephalopod/core/board/board_durations.dart';
import 'package:cephalopod/features/game/presentation/bloc/move_timing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('settleDurationFor', () {
    test('is the die animation when nothing was captured', () {
      expect(settleDurationFor(0), dieAnimationDuration);
    });

    test('is the same for a single capture', () {
      expect(settleDurationFor(1), dieAnimationDuration);
    });

    test('adds one stagger for each die after the first', () {
      expect(settleDurationFor(2), const Duration(milliseconds: 650));
      expect(settleDurationFor(4), const Duration(milliseconds: 950));
    });

    test('always lasts at least as long as the dice move', () {
      for (var captures = 0; captures <= 4; captures++) {
        expect(
          settleDurationFor(captures),
          greaterThanOrEqualTo(dieAnimationDuration),
        );
      }
    });
  });
}
