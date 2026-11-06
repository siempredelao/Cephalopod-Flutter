import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Starts a new game and saves it, replacing any saved game.
final class StartNewGame {
  StartNewGame({required this._cephalopodRules, required this._gameRepository});

  final CephalopodRules _cephalopodRules;
  final GameRepository _gameRepository;

  /// A new game under [config], already saved.
  Future<CurrentGame> call([GameConfig config = GameConfig.standard]) async {
    final record = GameRecord(config: config);
    await _gameRepository.save(record);
    return (record: record, state: _cephalopodRules.newGame(config));
  }
}
