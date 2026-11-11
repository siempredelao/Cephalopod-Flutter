import 'package:cephalopod/features/game/data/in_memory_how_to_play_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'how_to_play_repository_contract.dart';

void main() {
  testHowToPlayRepositoryContract(
    () async => InMemoryHowToPlayRepository(),
  );

  test('can start with How to play already seen', () async {
    final repository = InMemoryHowToPlayRepository(seenHowToPlay: true);

    expect(await repository.hasSeenHowToPlay(), isTrue);
  });
}
