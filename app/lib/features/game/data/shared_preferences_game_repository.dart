import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/game/data/saved_game_json_codec.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [GameRepository] that keeps the game on the device with
/// shared_preferences, as the JSON of [SavedGameJsonCodec]. Works on every
/// platform the app ships to, the web included (docs/adr/0012).
///
/// Storage never stops the game (docs/adr/0016). When shared_preferences
/// fails, the error goes to the [ErrorReporter] and the game goes on:
///
/// - A failed [save] or [clear] changes nothing on the device, but the game
///   on screen goes on.
/// - A failed [load] gives `null`, as if no game were saved, so a new game
///   starts.
///
/// Only `Exception`s are caught, which is how storage reports a failure. An
/// `Error` is a bug, so it goes on to the app-wide error reporting.
final class SharedPreferencesGameRepository implements GameRepository {
  SharedPreferencesGameRepository({
    required this._sharedPreferencesAsync,
    required this._savedGameJsonCodec,
    required this._errorReporter,
  });

  final SharedPreferencesAsync _sharedPreferencesAsync;
  final SavedGameJsonCodec _savedGameJsonCodec;
  final ErrorReporter _errorReporter;

  static const String _key = 'game';

  /// The saved game; `null` when there is none, when what is saved is not a
  /// game this version can read, or when storage fails.
  @override
  Future<SavedGame?> load() async {
    final String? json;
    try {
      json = await _sharedPreferencesAsync.getString(_key);
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'loading the saved game');
      return null;
    }
    return json == null ? null : _savedGameJsonCodec.decode(json);
  }

  @override
  Future<void> save(SavedGame savedGame) async {
    try {
      await _sharedPreferencesAsync.setString(
        _key,
        _savedGameJsonCodec.encode(savedGame),
      );
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'saving the game');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _sharedPreferencesAsync.remove(_key);
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'clearing the saved game');
    }
  }
}
