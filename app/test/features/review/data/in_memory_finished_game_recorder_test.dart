import 'package:cephalopod/features/review/data/in_memory_finished_game_recorder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'finished_game_recorder_contract.dart';

void main() {
  testFinishedGameRecorderContract(
    () async => inMemoryFinishedGameRecorder(),
  );

  test('can start with some games already finished', () async {
    final recordFinishedGame = inMemoryFinishedGameRecorder(finishedGames: 4);

    expect(await recordFinishedGame(), 5);
  });
}
