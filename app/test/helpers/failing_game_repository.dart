import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';

/// A [GameRepository] whose every call fails with [failure], like storage
/// that is broken or full.
final class FailingGameRepository implements GameRepository {
  FailingGameRepository(this.failure);

  /// What each call throws: an `Exception` for a storage failure, or an
  /// `Error` for a bug.
  final Object failure;

  @override
  Future<SavedGame?> load() => _fail();

  @override
  Future<void> save(SavedGame savedGame) => _fail();

  @override
  Future<void> clear() => _fail();

  Future<Never> _fail() async {
    Error.throwWithStackTrace(failure, StackTrace.current);
  }
}
