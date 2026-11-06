import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Plays a move and saves the game with it.
final class PlayMove {
  PlayMove({required this._cephalopodRules, required this._gameRepository});

  final CephalopodRules _cephalopodRules;
  final GameRepository _gameRepository;

  /// [game] after [move], already saved; or why [move] is illegal, in which
  /// case nothing is saved.
  Future<Result<CurrentGame, IllegalMove>> call(
    CurrentGame game,
    Move move,
  ) async {
    switch (_cephalopodRules.apply(game.state, move)) {
      case Ok(:final value):
        final record = GameRecord(
          config: game.record.config,
          moves: [...game.record.moves, move],
        );
        final opponent = game.opponent;
        await _gameRepository.save((record: record, opponent: opponent));
        return Ok((record: record, opponent: opponent, state: value));
      case Err(:final error):
        return Err(error);
    }
  }
}
