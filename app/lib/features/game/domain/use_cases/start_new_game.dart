import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Starts a new game and saves it, replacing any saved game.
final class StartNewGame {
  StartNewGame({required this._rules, required this._repository});

  final CephalopodRules _rules;
  final GameRepository _repository;

  /// A new game under [config], already saved.
  Future<CurrentGame> call([GameConfig config = GameConfig.standard]) async {
    final record = GameRecord(config: config);
    await _repository.save(record);
    return (record: record, state: _rules.newGame(config));
  }
}
