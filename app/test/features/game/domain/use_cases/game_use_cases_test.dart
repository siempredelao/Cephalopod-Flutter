import 'dart:async';

import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/choose_agent_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/has_game_to_continue.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/computer_turns.dart';
import '../../../../helpers/counting_game_repository.dart';

/// The game use cases, run against the real engine and an in-memory
/// repository: what each one returns, and what it leaves saved.
void main() {
  final rules = CephalopodRules();
  const center = Position(2, 2);
  const top = Position(0, 2);
  const friend = FriendOpponent();
  const computer = ComputerOpponent(
    difficulty: Difficulty.easy,
    player: Player.white,
  );

  late InMemoryGameRepository repository;
  late StartNewGame startNewGame;
  late PlayMove playMove;
  late UndoMove undoMove;
  late ResumeGame resumeGame;

  setUp(() {
    repository = InMemoryGameRepository();
    startNewGame = StartNewGame(
      cephalopodRules: rules,
      gameRepository: repository,
    );
    playMove = PlayMove(cephalopodRules: rules, gameRepository: repository);
    undoMove = UndoMove(cephalopodRules: rules, gameRepository: repository);
    resumeGame = ResumeGame(cephalopodRules: rules, gameRepository: repository);
  });

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

  group('StartNewGame', () {
    test('starts and saves a new game under the config', () async {
      const config = GameConfig(boardSize: 3);

      final game = await startNewGame(config: config, opponent: friend);

      expect(game.state, rules.newGame(config));
      expect(game.record, GameRecord(config: config));
      expect(await repository.load(), saved(game));
    });

    test('saves the opponent with the game', () async {
      final game = await startNewGame(opponent: computer);

      expect(game.opponent, computer);
      expect(await repository.load(), saved(game));
    });

    test('replaces the saved game', () async {
      final start = await startNewGame(opponent: friend);
      final old = await play(start, Move(center));

      final game = await startNewGame(opponent: friend);

      expect(game.record.moves, isEmpty);
      expect(await repository.load(), isNot(saved(old)));
    });
  });

  group('PlayMove', () {
    test('plays the move and saves the game with it', () async {
      final start = await startNewGame(opponent: friend);

      final game = await play(start, Move(center));

      expect(game.record.moves, [Move(center)]);
      expect(game.state.board.dice[center]?.owner, Player.black);
      expect(await repository.load(), saved(game));
    });

    test('keeps the opponent', () async {
      final start = await startNewGame(opponent: computer);

      final game = await play(start, Move(center));

      expect(game.opponent, computer);
      expect(await repository.load(), saved(game));
    });

    test('R2: refuses an illegal move and saves nothing', () async {
      final start = await startNewGame(opponent: friend);
      final game = await play(start, Move(center));

      final result = await playMove(game, Move(center));

      expect(result, isA<Err<CurrentGame, IllegalMove>>());
      expect(await repository.load(), saved(game));
    });
  });

  group('UndoMove', () {
    test('takes back the last move and saves the game without it', () async {
      final start = await startNewGame(opponent: computer);
      final first = await play(start, Move(center));
      final second = await play(first, Move(top));

      final undone = await undoMove(second);

      expect(undone, first);
      expect(await repository.load(), saved(first));
    });

    test('leaves a game with no moves as it is', () async {
      final start = await startNewGame(opponent: friend);

      expect(await undoMove(start), start);
    });

    test('takes back several moves with one save', () async {
      final counting = CountingGameRepository();
      final undoTwo = UndoMove(
        cephalopodRules: rules,
        gameRepository: counting,
      );
      final start = await startNewGame(opponent: computer);
      final first = await play(start, Move(center));
      final third = await play(
        await play(first, Move(top)),
        Move(const Position(4, 4)),
      );

      final undone = await undoTwo(third, count: 2);

      expect(undone, first);
      expect(await counting.load(), saved(first));
      expect(counting.saves, 1);
    });

    test('takes back every move when asked for more', () async {
      final start = await startNewGame(opponent: friend);
      final first = await play(start, Move(center));

      final undone = await undoMove(first, count: 5);

      expect(undone, start);
      expect(await repository.load(), saved(start));
    });

    test('refuses a negative count', () async {
      final start = await startNewGame(opponent: friend);
      final first = await play(start, Move(center));

      await expectLater(undoMove(first, count: -1), throwsRangeError);
    });

    test('fails loudly on a record its moves could not build', () async {
      final start = await startNewGame(opponent: friend);
      final moves = [Move(center), Move(center), Move(top)];
      final forged = (
        record: GameRecord(moves: moves),
        opponent: friend,
        state: start.state,
      );

      expect(undoMove(forged), throwsStateError);
    });
  });

  group('ResumeGame', () {
    test('has nothing to resume before a game is saved', () async {
      expect(await resumeGame(), isNull);
    });

    test('rebuilds the saved game from its moves', () async {
      final start = await startNewGame(opponent: computer);
      final first = await play(start, Move(center));
      final second = await play(first, Move(top));

      expect(await resumeGame(), second);
    });

    test('clears a save it cannot replay, and starts nothing', () async {
      final corrupt = GameRecord(moves: [Move(center), Move(center)]);
      await repository.save((record: corrupt, opponent: friend));

      expect(await resumeGame(), isNull);
      expect(await repository.load(), isNull);
    });
  });

  group('HasGameToContinue', () {
    late HasGameToContinue hasGameToContinue;

    setUp(() {
      hasGameToContinue = HasGameToContinue(resumeGame: resumeGame);
    });

    test('says no when nothing is saved', () async {
      expect(await hasGameToContinue(), isFalse);
    });

    test('says no for a new game with no moves yet', () async {
      await startNewGame(opponent: friend);

      expect(await hasGameToContinue(), isFalse);
    });

    test('says yes once a move is played', () async {
      await play(await startNewGame(opponent: friend), Move(center));

      expect(await hasGameToContinue(), isTrue);
    });

    test('R8: says no once the game is over', () async {
      const oneSquare = GameConfig(boardSize: 1);
      final start = await startNewGame(config: oneSquare, opponent: friend);
      await play(start, Move(const Position(0, 0)));

      expect(await hasGameToContinue(), isFalse);
    });
  });

  group('ChooseAgentMove', () {
    final agentMove = Move(top);
    late _FixedAgent agent;
    late List<Difficulty> difficulties;
    late int backgroundRuns;
    late ChooseAgentMove chooseAgentMove;

    /// Runs the agent here, and counts the runs.
    Future<R> countingRunner<M, R>(
      FutureOr<R> Function(M message) callback,
      M message,
    ) {
      backgroundRuns++;
      return runHere(callback, message);
    }

    setUp(() {
      agent = _FixedAgent(agentMove);
      difficulties = [];
      backgroundRuns = 0;
      chooseAgentMove = ChooseAgentMove(
        agentFactory: (difficulty) {
          difficulties.add(difficulty);
          return agent;
        },
        backgroundRunner: countingRunner,
      );
    });

    /// A game against [opponent] after black's first move, so white is to
    /// move: the computer's turn, if it plays white.
    Future<CurrentGame> computerToMove([Opponent opponent = computer]) async {
      final start = await startNewGame(opponent: opponent);
      return play(start, Move(center));
    }

    test('gives the move the agent chooses, and saves nothing', () async {
      final game = await computerToMove();

      final move = await chooseAgentMove(game);

      expect(agent.positions, [game.state]);
      expect(move, agentMove);
      expect(await repository.load(), saved(game));
    });

    test('lets the agent choose in the background', () async {
      await chooseAgentMove(await computerToMove());

      expect(backgroundRuns, 1);
    });

    test("knows when it is the computer's turn", () async {
      final start = await startNewGame(opponent: computer);
      final againstFriend = await computerToMove(friend);

      expect(chooseAgentMove.isComputerTurn(start), isFalse);
      expect(chooseAgentMove.isComputerTurn(await computerToMove()), isTrue);
      expect(chooseAgentMove.isComputerTurn(againstFriend), isFalse);
    });

    test("asks for the agent of the computer's difficulty", () async {
      for (final difficulty in Difficulty.values) {
        final opponent = ComputerOpponent(
          difficulty: difficulty,
          player: Player.white,
        );
        await chooseAgentMove(await computerToMove(opponent));
      }

      expect(difficulties, Difficulty.values);
    });

    test('refuses a game against a friend', () async {
      final game = await computerToMove(friend);

      await expectLater(chooseAgentMove(game), throwsArgumentError);
    });

    test("refuses when it is the person's turn", () async {
      final start = await startNewGame(opponent: computer);

      await expectLater(chooseAgentMove(start), throwsArgumentError);
    });

    test('refuses a game that is over', () async {
      const oneSquare = GameConfig(boardSize: 1);
      final start = await startNewGame(config: oneSquare, opponent: computer);
      final over = await play(start, Move(const Position(0, 0)));

      await expectLater(chooseAgentMove(over), throwsArgumentError);
    });
  });
}

/// An agent that always chooses [move], and keeps each position it is
/// asked about.
final class _FixedAgent implements GameAgent {
  _FixedAgent(this.move);

  final Move move;
  final List<GameState> positions = [];

  @override
  Move chooseMove(GameState state) {
    positions.add(state);
    return move;
  }
}
