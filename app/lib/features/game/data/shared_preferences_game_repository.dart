import 'package:cephalopod/features/game/data/game_record_json_codec.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [GameRepository] that keeps the game on the device with
/// shared_preferences, as the JSON of [GameRecordJsonCodec]. Works on every
/// platform the app ships to, the web included (docs/adr/0012).
final class SharedPreferencesGameRepository implements GameRepository {
  SharedPreferencesGameRepository({
    required this._preferences,
    required this._codec,
  });

  final SharedPreferencesAsync _preferences;
  final GameRecordJsonCodec _codec;

  static const String _key = 'game';

  /// The saved game; `null` when there is none, or when what is saved is not
  /// a game this version can read.
  @override
  Future<GameRecord?> load() async {
    final json = await _preferences.getString(_key);
    return json == null ? null : _codec.decode(json);
  }

  @override
  Future<void> save(GameRecord record) {
    return _preferences.setString(_key, _codec.encode(record));
  }

  @override
  Future<void> clear() => _preferences.remove(_key);
}
