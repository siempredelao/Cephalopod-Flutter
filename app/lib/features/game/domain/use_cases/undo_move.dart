import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Takes back the last move and saves the game without it.
final class UndoMove {
  UndoMove({required this._rules, required this._repository});

  final CephalopodRules _rules;
  final GameRepository _repository;

  /// [game] without its last move, already saved; [game] itself when no move
  /// has been played.
  ///
  /// The position comes from replaying the moves that are left
  /// (docs/adr/0003), so undo and resume share one code path.
  Future<CurrentGame> call(CurrentGame game) async {
    final moves = game.record.moves;
    if (moves.isEmpty) return game;
    final record = GameRecord(
      config: game.record.config,
      moves: moves.sublist(0, moves.length - 1),
    );
    final state = switch (_rules.replay(record)) {
      Ok(:final value) => value,
      // Each move was legal when it was played, so the moves before the last
      // one replay. Failing here means the record was built some other way.
      Err(:final error) => throw StateError('Cannot replay $record: $error'),
    };
    await _repository.save(record);
    return (record: record, state: state);
  }
}
