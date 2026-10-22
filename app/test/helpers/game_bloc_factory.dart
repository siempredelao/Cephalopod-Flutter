import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A [GameBloc] on the real engine and [repository] (in memory by default),
/// wired the way the composition root wires it to device storage.
GameBloc createTestGameBloc({
  GameRepository? repository,
  GameConfig config = GameConfig.standard,
}) {
  final rules = CephalopodRules();
  final games = repository ?? InMemoryGameRepository();
  final startNewGame = StartNewGame(rules: rules, repository: games);
  final playMove = PlayMove(rules: rules, repository: games);
  final undoMove = UndoMove(rules: rules, repository: games);
  final resumeGame = ResumeGame(rules: rules, repository: games);
  return GameBloc(
    rules: rules,
    startNewGame: startNewGame,
    playMove: playMove,
    undoMove: undoMove,
    resumeGame: resumeGame,
    config: config,
  );
}
