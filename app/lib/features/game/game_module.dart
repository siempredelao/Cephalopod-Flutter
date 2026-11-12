import 'dart:math';

import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/dialog_page.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/sound_effects.dart';
import 'package:cephalopod/features/game/domain/sound_effects_proxy.dart';
import 'package:cephalopod/features/game/domain/use_cases/choose_agent_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/has_game_to_continue.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/suggest_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/countdown_timer.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/opponent_query_codec.dart';
import 'package:cephalopod/features/game/presentation/view/game_durations.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/new_game_dialog.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:go_router/go_router.dart';

/// Wires the game feature. Its use cases are built once, the first time
/// they are needed, on the rules and the repository the composition root
/// picks, and each visit to the game route gets its own [GameBloc].
final class GameModule implements FeatureModule {
  /// `highlightLastMove` and `soundOn` are plain functions rather than the
  /// settings feature's cubit, because features may not import each other.
  /// The composition root wires them to the settings module.
  GameModule({
    required this._cephalopodRules,
    required this._gameRepository,
    required this._soundEffects,
    required this._highlightLastMove,
    required this._soundOn,
  });

  final CephalopodRules _cephalopodRules;
  final GameRepository _gameRepository;
  final SoundEffects _soundEffects;
  final bool Function() _highlightLastMove;
  final bool Function() _soundOn;

  /// The game's sounds, heard only while the Sound switch is on.
  late final SoundEffects _soundEffectsProxy = SoundEffectsProxy(
    soundEffects: _soundEffects,
    soundOn: _soundOn,
  );

  final PositionEvaluator _positionEvaluator = PositionEvaluator();
  final OpponentQueryCodec _opponentQueryCodec = const OpponentQueryCodec();

  late final StartNewGame _startNewGame = StartNewGame(
    cephalopodRules: _cephalopodRules,
    gameRepository: _gameRepository,
  );
  late final PlayMove _playMove = PlayMove(
    cephalopodRules: _cephalopodRules,
    gameRepository: _gameRepository,
  );
  late final UndoMove _undoMove = UndoMove(
    cephalopodRules: _cephalopodRules,
    gameRepository: _gameRepository,
  );
  late final ResumeGame _resumeGame = ResumeGame(
    cephalopodRules: _cephalopodRules,
    gameRepository: _gameRepository,
  );
  late final HasGameToContinue _hasGameToContinue = HasGameToContinue(
    resumeGame: _resumeGame,
  );

  /// The computer's moves are chosen with Flutter's `compute`, on another
  /// isolate, so the screen stays responsive while the Hard level thinks.
  late final ChooseAgentMove _chooseAgentMove = ChooseAgentMove(
    agentFactory: _agentFor,
    backgroundRunner: compute,
  );

  /// Hints come from the same agents, in the background too.
  late final SuggestMove _suggestMove = SuggestMove(
    agentFactory: _agentFor,
    backgroundRunner: compute,
  );

  /// Whether there is a saved game worth continuing. A plain function, so
  /// the composition root can hand it to features that may not import this
  /// one.
  Future<bool> hasGameToContinue() => _hasGameToContinue();

  /// The new-game route is a dialog that chooses an opponent and closes with
  /// the game's location. The game route starts a game against the opponent
  /// in its query (`OpponentQueryCodec`), or picks up the saved one with
  /// `?resume=true`, which Home offers when there is one.
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: 'new-game',
      name: AppRoute.newGame.name,
      pageBuilder: (_, state) => DialogPage<String>(
        key: state.pageKey,
        builder: (_) => const NewGameDialog(),
      ),
    ),
    GoRoute(
      path: 'game',
      name: AppRoute.game.name,
      // Settings cannot change while a game is on screen, so the game reads
      // the highlight setting once, when it opens.
      builder: (_, state) => GamePage(
        createBloc: _createBloc,
        opening: _openingOf(state.uri.queryParameters),
      ),
    ),
  ];

  /// The game route's first event, from its query parameters.
  GameEvent _openingOf(Map<String, String> parameters) {
    if (parameters['resume'] == 'true') return const GameResumed();
    return GameStarted(opponent: _opponentQueryCodec.decode(parameters));
  }

  GameBloc _createBloc() {
    return GameBloc(
      cephalopodRules: _cephalopodRules,
      startNewGame: _startNewGame,
      playMove: _playMove,
      undoMove: _undoMove,
      resumeGame: _resumeGame,
      chooseAgentMove: _chooseAgentMove,
      suggestMove: _suggestMove,
      highlightLastMove: _highlightLastMove(),
      soundEffects: _soundEffectsProxy,
      moveCountdown: CountdownTimer(moveSettleDuration),
    );
  }

  /// Which agent plays each difficulty (docs/adr/0014), with a new `Random`
  /// for every move, as `AgentFactory` asks.
  GameAgent _agentFor(Difficulty difficulty) {
    final random = Random();
    return switch (difficulty) {
      Difficulty.easy => RandomAgent(
        moveGenerator: _cephalopodRules,
        random: random,
      ),
      Difficulty.medium => GreedyAgent(
        moveGenerator: _cephalopodRules,
        positionEvaluator: _positionEvaluator,
        random: random,
      ),
      Difficulty.hard => SearchAgent(
        moveGenerator: _cephalopodRules,
        positionEvaluator: _positionEvaluator,
        random: random,
      ),
    };
  }
}
