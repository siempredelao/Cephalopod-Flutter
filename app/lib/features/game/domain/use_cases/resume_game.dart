import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Picks up the saved game.
final class ResumeGame {
  ResumeGame({required this._cephalopodRules, required this._gameRepository});

  final CephalopodRules _cephalopodRules;
  final GameRepository _gameRepository;

  /// The saved game, rebuilt by replaying its moves; `null` when there is
  /// none.
  ///
  /// A save that cannot be replayed, such as a corrupted one, also gives
  /// `null` and is cleared, so the next game starts fresh instead of failing
  /// again (docs/adr/0003).
  Future<CurrentGame?> call() async {
    final savedGame = await _gameRepository.load();
    if (savedGame == null) return null;
    switch (_cephalopodRules.replay(savedGame.record)) {
      case Ok(:final value):
        return (
          record: savedGame.record,
          opponent: savedGame.opponent,
          state: value,
        );
      case Err():
        await _gameRepository.clear();
        return null;
    }
  }
}
