import 'package:cephalopod/features/home/data/in_memory_first_launch_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'first_launch_repository_contract.dart';

void main() {
  testFirstLaunchRepositoryContract(
    () async => InMemoryFirstLaunchRepository(),
  );

  test('can start with How to play already seen', () async {
    final repository = InMemoryFirstLaunchRepository(seenHowToPlay: true);

    expect(await repository.hasSeenHowToPlay(), isTrue);
  });
}
