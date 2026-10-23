import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Picks up the saved game.
final class ResumeGame {
  ResumeGame({required this._rules, required this._repository});

  final CephalopodRules _rules;
  final GameRepository _repository;

  /// The saved game, rebuilt by replaying its moves; `null` when there is
  /// none.
  ///
  /// A save that cannot be replayed, such as a corrupted one, also gives
  /// `null` and is cleared, so the next game starts fresh instead of failing
  /// again (docs/adr/0003).
  Future<CurrentGame?> call() async {
    final record = await _repository.load();
    if (record == null) return null;
    switch (_rules.replay(record)) {
      case Ok(:final value):
        return (record: record, state: value);
      case Err():
        await _repository.clear();
        return null;
    }
  }
}
