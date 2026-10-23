import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod/features/game/data/game_record_json_codec.dart';
import 'package:cephalopod/features/game/data/shared_preferences_game_repository.dart';
import 'package:cephalopod/features/game/domain/use_cases/has_game_to_continue.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: the only code that creates concrete dependencies and
/// wires them together. Everything else receives them through constructors.
void bootstrap(Flavor flavor) {
  final rules = CephalopodRules();
  final games = SharedPreferencesGameRepository(
    preferences: SharedPreferencesAsync(),
    codec: GameRecordJsonCodec(),
  );
  final startNewGame = StartNewGame(rules: rules, repository: games);
  final playMove = PlayMove(rules: rules, repository: games);
  final undoMove = UndoMove(rules: rules, repository: games);
  final resumeGame = ResumeGame(rules: rules, repository: games);
  final hasGameToContinue = HasGameToContinue(resumeGame: resumeGame);

  HomeCubit createHomeCubit() {
    return HomeCubit(hasGameToContinue: hasGameToContinue.call);
  }

  GameBloc createGameBloc() {
    return GameBloc(
      rules: rules,
      startNewGame: startNewGame,
      playMove: playMove,
      undoMove: undoMove,
      resumeGame: resumeGame,
    );
  }

  final router = createRouter(
    createHomeCubit: createHomeCubit,
    createGameBloc: createGameBloc,
  );
  runApp(App(flavor: flavor, router: router));
}
