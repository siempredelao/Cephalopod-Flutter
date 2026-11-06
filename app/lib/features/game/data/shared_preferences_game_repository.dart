import 'package:cephalopod/features/game/data/saved_game_json_codec.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [GameRepository] that keeps the game on the device with
/// shared_preferences, as the JSON of [SavedGameJsonCodec]. Works on every
/// platform the app ships to, the web included (docs/adr/0012).
final class SharedPreferencesGameRepository implements GameRepository {
  SharedPreferencesGameRepository({
    required this._sharedPreferencesAsync,
    required this._savedGameJsonCodec,
  });

  final SharedPreferencesAsync _sharedPreferencesAsync;
  final SavedGameJsonCodec _savedGameJsonCodec;

  static const String _key = 'game';

  /// The saved game; `null` when there is none, or when what is saved is not
  /// a game this version can read.
  @override
  Future<SavedGame?> load() async {
    final json = await _sharedPreferencesAsync.getString(_key);
    return json == null ? null : _savedGameJsonCodec.decode(json);
  }

  @override
  Future<void> save(SavedGame savedGame) {
    return _sharedPreferencesAsync.setString(
      _key,
      _savedGameJsonCodec.encode(savedGame),
    );
  }

  @override
  Future<void> clear() => _sharedPreferencesAsync.remove(_key);
}
