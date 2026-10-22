import 'package:cephalopod/features/game/domain/current_game.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Plays a move and saves the game with it.
final class PlayMove {
  PlayMove({required this._rules, required this._repository});

  final CephalopodRules _rules;
  final GameRepository _repository;

  /// [game] after [move], already saved; or why [move] is illegal, in which
  /// case nothing is saved.
  Future<Result<CurrentGame, IllegalMove>> call(
    CurrentGame game,
    Move move,
  ) async {
    switch (_rules.apply(game.state, move)) {
      case Ok(:final value):
        final record = GameRecord(
          config: game.record.config,
          moves: [...game.record.moves, move],
        );
        await _repository.save(record);
        return Ok((record: record, state: value));
      case Err(:final error):
        return Err(error);
    }
  }
}
