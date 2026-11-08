import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/agent_factory.dart';
import 'package:cephalopod/features/game/domain/background_runner.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/use_cases/choose_agent_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

import 'computer_turns.dart';

/// A [GameBloc] on the real engine and [repository] (in memory by default),
/// wired the way the composition root wires it to device storage.
///
/// The computer plays its first legal move, unless [agentFactory] gives
/// another agent, on the test's isolate unless [backgroundRunner] says
/// otherwise. The bloc starts from a new game under [config], or from
/// [position] when given.
GameBloc createTestGameBloc({
  GameRepository? repository,
  GameConfig config = GameConfig.standard,
  GameState? position,
  BackgroundRunner backgroundRunner = runHere,
  AgentFactory? agentFactory,
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
  final chooseAgentMove = ChooseAgentMove(
    agentFactory: agentFactory ?? (_) => FirstMoveAgent(rules),
    backgroundRunner: backgroundRunner,
  );
  return GameBloc(
    cephalopodRules: rules,
    startNewGame: startNewGame,
    playMove: playMove,
    undoMove: undoMove,
    resumeGame: resumeGame,
    chooseAgentMove: chooseAgentMove,
    config: config,
    position: position,
  );
}
