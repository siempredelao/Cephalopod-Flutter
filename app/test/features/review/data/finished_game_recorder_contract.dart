import 'package:cephalopod/features/review/domain/finished_game_recorder.dart';
import 'package:flutter_test/flutter_test.dart';

/// What every [FinishedGameRecorder] must do. Each implementation's test
/// calls this with a way to create a fresh recorder that has counted
/// nothing.
void testFinishedGameRecorderContract(
  Future<FinishedGameRecorder> Function() create,
) {
  group('FinishedGameRecorder contract', () {
    late FinishedGameRecorder recordFinishedGame;

    setUp(() async => recordFinishedGame = await create());

    test('counts the first game as 1', () async {
      expect(await recordFinishedGame(), 1);
    });

    test('counts one more with each finished game', () async {
      await recordFinishedGame();
      await recordFinishedGame();

      expect(await recordFinishedGame(), 3);
    });
  });
}
