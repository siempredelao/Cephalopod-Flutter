import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/background_runner.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/request_agent_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

import 'computer_turns.dart';

/// A [GameBloc] on the real engine and [repository] (in memory by default),
/// wired the way the composition root wires it to device storage.
///
/// The computer always plays its first legal move, on the test's isolate
/// unless [backgroundRunner] says otherwise.
GameBloc createTestGameBloc({
  GameRepository? repository,
  GameConfig config = GameConfig.standard,
  BackgroundRunner backgroundRunner = runHere,
}) {
  final rules = CephalopodRules();
  final games = repository ?? InMemoryGameRepository();
  final startNewGame = StartNewGame(
    cephalopodRules: rules,
    gameRepository: games,
  );
  final playMove = PlayMove(cephalopodRules: rules, gameRepository: games);
  final undoMove = UndoMove(cephalopodRules: rules, gameRepository: games);
  final resumeGame = ResumeGame(cephalopodRules: rules, gameRepository: games);
  final requestAgentMove = RequestAgentMove(
    agentFactory: (_) => FirstMoveAgent(rules),
    backgroundRunner: backgroundRunner,
    playMove: playMove,
  );
  return GameBloc(
    cephalopodRules: rules,
    startNewGame: startNewGame,
    playMove: playMove,
    undoMove: undoMove,
    resumeGame: resumeGame,
    requestAgentMove: requestAgentMove,
    config: config,
  );
}
