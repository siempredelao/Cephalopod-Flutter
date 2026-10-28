import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/use_cases/has_game_to_continue.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/how_to_play_page.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:go_router/go_router.dart';

/// Wires the game feature. Its use cases are built once, the first time
/// they are needed, on the rules and the repository the composition root
/// picks, and each visit to the game route gets its own [GameBloc].
final class GameModule implements FeatureModule {
  /// `highlightLastMove` is a plain function rather than the settings
  /// feature's cubit, because features may not import each other. The
  /// composition root wires it to the settings module.
  GameModule({
    required this._rules,
    required this._repository,
    required this._highlightLastMove,
  });

  final CephalopodRules _rules;
  final GameRepository _repository;
  final bool Function() _highlightLastMove;

  late final StartNewGame _startNewGame = StartNewGame(
    rules: _rules,
    repository: _repository,
  );
  late final PlayMove _playMove = PlayMove(
    rules: _rules,
    repository: _repository,
  );
  late final UndoMove _undoMove = UndoMove(
    rules: _rules,
    repository: _repository,
  );
  late final ResumeGame _resumeGame = ResumeGame(
    rules: _rules,
    repository: _repository,
  );
  late final HasGameToContinue _hasGameToContinue = HasGameToContinue(
    resumeGame: _resumeGame,
  );

  /// Whether there is a saved game worth continuing. A plain function, so
  /// the composition root can hand it to features that may not import this
  /// one.
  Future<bool> hasGameToContinue() => _hasGameToContinue();

  /// The game route starts a new game, or picks up the saved one with
  /// `?resume=true`, which Home offers when there is one.
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: 'game',
      name: AppRoute.game.name,
      // Settings cannot change while a game is on screen, so the game reads
      // the highlight setting once, when it opens.
      builder: (_, state) => GamePage(
        createBloc: _createBloc,
        resume: state.uri.queryParameters['resume'] == 'true',
        highlightLastMove: _highlightLastMove(),
      ),
    ),
    GoRoute(
      path: 'how-to-play',
      name: AppRoute.howToPlay.name,
      builder: (_, _) => const HowToPlayPage(),
    ),
  ];

  GameBloc _createBloc() {
    return GameBloc(
      rules: _rules,
      startNewGame: _startNewGame,
      playMove: _playMove,
      undoMove: _undoMove,
      resumeGame: _resumeGame,
    );
  }
}
