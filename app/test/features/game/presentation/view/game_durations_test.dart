import 'package:cephalopod/core/board/board_durations.dart';
import 'package:cephalopod/features/game/presentation/view/game_durations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('durations', () {
    test('the game waits for a move at least as long as its dice move', () {
      expect(moveSettleDuration, greaterThanOrEqualTo(dieAnimationDuration));
    });
  });
}
