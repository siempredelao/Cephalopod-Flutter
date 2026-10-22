import 'package:cephalopod/features/game/data/game_record_json_codec.dart';
import 'package:cephalopod/features/game/data/shared_preferences_game_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'game_repository_contract.dart';

void main() {
  /// A repository on fresh, empty in-memory preferences.
  SharedPreferencesGameRepository create() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    return SharedPreferencesGameRepository(
      preferences: SharedPreferencesAsync(),
      codec: GameRecordJsonCodec(),
    );
  }

  testGameRepositoryContract(() async => create());

  group('SharedPreferencesGameRepository', () {
    test('has no game when the save cannot be read', () async {
      final repository = create();
      await SharedPreferencesAsync().setString('game', 'not json');

      expect(await repository.load(), isNull);
    });
  });
}
