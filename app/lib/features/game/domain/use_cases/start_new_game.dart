import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Starts a new game and saves it, replacing any saved game.
final class StartNewGame {
  StartNewGame({required this._cephalopodRules, required this._gameRepository});

  final CephalopodRules _cephalopodRules;
  final GameRepository _gameRepository;

  /// A new game against [opponent] under [config], already saved.
  Future<CurrentGame> call({
    required Opponent opponent,
    GameConfig config = GameConfig.standard,
  }) async {
    final record = GameRecord(config: config);
    final state = _cephalopodRules.newGame(config);
    await _gameRepository.save((record: record, opponent: opponent));
    return (record: record, opponent: opponent, state: state);
  }
}
