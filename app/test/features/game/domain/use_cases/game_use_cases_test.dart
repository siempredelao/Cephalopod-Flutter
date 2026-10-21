import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/current_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// The game use cases, run against the real engine and an in-memory
/// repository: what each one returns, and what it leaves saved.
void main() {
  final rules = CephalopodRules();
  const center = Position(2, 2);
  const top = Position(0, 2);

  late InMemoryGameRepository repository;
  late StartNewGame startNewGame;
  late PlayMove playMove;
  late UndoMove undoMove;
  late ResumeGame resumeGame;

  setUp(() {
    repository = InMemoryGameRepository();
    startNewGame = StartNewGame(rules: rules, repository: repository);
    playMove = PlayMove(rules: rules, repository: repository);
    undoMove = UndoMove(rules: rules, repository: repository);
    resumeGame = ResumeGame(rules: rules, repository: repository);
  });

  /// [game] after [move], which the test expects to be legal.
  Future<CurrentGame> play(CurrentGame game, Move move) async {
    return switch (await playMove(game, move)) {
      Ok(:final value) => value,
      Err(:final error) => throw StateError('Illegal test move: $error'),
    };
  }

  group('StartNewGame', () {
    test('starts and saves a new game under the config', () async {
      const config = GameConfig(boardSize: 3);

      final game = await startNewGame(config);

      expect(game.state, rules.newGame(config));
      expect(game.record, GameRecord(config: config));
      expect(await repository.load(), game.record);
    });

    test('replaces the saved game', () async {
      final old = await play(await startNewGame(), Move(center));

      final game = await startNewGame();

      expect(game.record.moves, isEmpty);
      expect(await repository.load(), isNot(old.record));
    });
  });

  group('PlayMove', () {
    test('plays the move and saves the game with it', () async {
      final start = await startNewGame();

      final game = await play(start, Move(center));

      expect(game.record.moves, [Move(center)]);
      expect(game.state.board.dice[center]?.owner, Player.black);
      expect(await repository.load(), game.record);
    });

    test('R2: refuses an illegal move and saves nothing', () async {
      final game = await play(await startNewGame(), Move(center));

      final result = await playMove(game, Move(center));

      expect(result, isA<Err<CurrentGame, IllegalMove>>());
      expect(await repository.load(), game.record);
    });
  });

  group('UndoMove', () {
    test('takes back the last move and saves the game without it', () async {
      final start = await startNewGame();
      final first = await play(start, Move(center));
      final second = await play(first, Move(top));

      final undone = await undoMove(second);

      expect(undone, first);
      expect(await repository.load(), first.record);
    });

    test('leaves a game with no moves as it is', () async {
      final start = await startNewGame();

      expect(await undoMove(start), start);
    });

    test('fails loudly on a record its moves could not build', () async {
      final start = await startNewGame();
      final moves = [Move(center), Move(center), Move(top)];
      final forged = (record: GameRecord(moves: moves), state: start.state);

      expect(undoMove(forged), throwsStateError);
    });
  });

  group('ResumeGame', () {
    test('has nothing to resume before a game is saved', () async {
      expect(await resumeGame(), isNull);
    });

    test('rebuilds the saved game from its moves', () async {
      final first = await play(await startNewGame(), Move(center));
      final second = await play(first, Move(top));

      expect(await resumeGame(), second);
    });

    test('clears a save it cannot replay, and starts nothing', () async {
      final corrupt = GameRecord(moves: [Move(center), Move(center)]);
      await repository.save(corrupt);

      expect(await resumeGame(), isNull);
      expect(await repository.load(), isNull);
    });
  });
}
