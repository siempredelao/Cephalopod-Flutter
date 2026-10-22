import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';

import 'game_repository_contract.dart';

void main() {
  testGameRepositoryContract(() async => InMemoryGameRepository());
}
