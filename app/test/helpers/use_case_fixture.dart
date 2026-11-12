import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// The middle square of the default board.
const center = Position(2, 2);

/// A square at the top edge of the default board.
const top = Position(0, 2);

/// An opponent who is another person on the same device.
const friend = FriendOpponent();

/// An easy computer opponent that plays white.
const computer = ComputerOpponent(
  difficulty: Difficulty.easy,
  player: Player.white,
);

/// What the game use case tests share: the real rules, an in-memory
/// repository, the four use cases that need only those two, and two helpers
/// to set a game up. Make a new one in each test's `setUp`.
final class UseCaseFixture {
  UseCaseFixture() {
    startNewGame = StartNewGame(
      cephalopodRules: rules,
      gameRepository: repository,
    );
    playMove = PlayMove(cephalopodRules: rules, gameRepository: repository);
    undoMove = UndoMove(cephalopodRules: rules, gameRepository: repository);
    resumeGame = ResumeGame(cephalopodRules: rules, gameRepository: repository);
  }

  final CephalopodRules rules = CephalopodRules();
  final InMemoryGameRepository repository = InMemoryGameRepository();

  late final StartNewGame startNewGame;
  late final PlayMove playMove;
  late final UndoMove undoMove;
  late final ResumeGame resumeGame;

  /// What [game] leaves saved: its record and opponent.
  SavedGame saved(CurrentGame game) {
    return (record: game.record, opponent: game.opponent);
  }

  /// [game] after [move], which the test expects to be legal.
  Future<CurrentGame> play(CurrentGame game, Move move) async {
    return switch (await playMove(game, move)) {
      Ok(:final value) => value,
      Err(:final error) => throw StateError('Illegal test move: $error'),
    };
  }
}
