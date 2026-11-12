import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/agent_factory.dart';
import 'package:cephalopod/features/game/domain/background_runner.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/sound_effects.dart';
import 'package:cephalopod/features/game/domain/use_cases/choose_agent_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/suggest_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/countdown_timer.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

import 'computer_turns.dart';
import 'fake_sound_effects.dart';

/// A [GameBloc] on the real engine and [repository] (in memory by default),
/// wired the way the composition root wires it to device storage.
///
/// The computer plays its first legal move, and hints suggest it too,
/// unless [agentFactory] gives another agent, on the test's isolate unless
/// [backgroundRunner] says otherwise. After a move, the bloc runs
/// [moveCountdown], which has no length by default. The bloc starts from a
/// new game under [config], or from [position] when given. It plays its
/// sounds on [soundEffects], or on a fake that only records them.
GameBloc createTestGameBloc({
  GameRepository? repository,
  GameConfig config = GameConfig.standard,
  GameState? position,
  BackgroundRunner backgroundRunner = runHere,
  AgentFactory? agentFactory,
  CountdownTimer? moveCountdown,
  SoundEffects? soundEffects,
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
  final agents = agentFactory ?? (_) => FirstMoveAgent(rules);
  final chooseAgentMove = ChooseAgentMove(
    agentFactory: agents,
    backgroundRunner: backgroundRunner,
  );
  final suggestMove = SuggestMove(
    agentFactory: agents,
    backgroundRunner: backgroundRunner,
  );
  return GameBloc(
    cephalopodRules: rules,
    startNewGame: startNewGame,
    playMove: playMove,
    undoMove: undoMove,
    resumeGame: resumeGame,
    chooseAgentMove: chooseAgentMove,
    suggestMove: suggestMove,
    moveCountdown: moveCountdown,
    soundEffects: soundEffects ?? FakeSoundEffects(),
    config: config,
    position: position,
  );
}
