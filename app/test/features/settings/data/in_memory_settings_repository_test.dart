import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';

import 'settings_repository_contract.dart';

void main() {
  testSettingsRepositoryContract(() async => InMemorySettingsRepository());
}
