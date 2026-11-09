import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';

/// A [GameRepository] that never lets storage stop the game
/// (docs/adr/0016). It passes every call on to the repository it wraps, and
/// when storage fails, reports the error and carries on:
///
/// - A failed `save` or `clear` changes nothing on the device, but the game
///   on screen goes on.
/// - A failed `load` gives `null`, as if no game were saved, so a new game
///   starts.
///
/// It catches only `Exception`s, which is how storage reports a failure. An
/// `Error` is a bug, so it goes on to the app-wide error reporting.
final class BestEffortGameRepository implements GameRepository {
  BestEffortGameRepository({
    required this._gameRepository,
    required this._errorReporter,
  });

  final GameRepository _gameRepository;
  final ErrorReporter _errorReporter;

  @override
  Future<SavedGame?> load() async {
    try {
      return await _gameRepository.load();
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'loading the saved game');
      return null;
    }
  }

  @override
  Future<void> save(SavedGame savedGame) async {
    try {
      await _gameRepository.save(savedGame);
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'saving the game');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _gameRepository.clear();
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'clearing the saved game');
    }
  }
}
