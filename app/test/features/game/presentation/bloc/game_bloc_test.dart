import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/game/data/best_effort_game_repository.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/failing_game_repository.dart';
import '../../../../helpers/game_bloc_factory.dart';

void main() {
  final rules = CephalopodRules();
  const center = Position(2, 2);
  const top = Position(0, 2);
  const left = Position(0, 1);
  const right = Position(0, 3);
  const below = Position(1, 2);

  GameBloc build() => createTestGameBloc();

  /// A bloc whose game starts at [position], as if play had reached it.
  GameBloc buildAt(GameState position) {
    return createTestGameBloc(position: position);
  }

  /// What the screen shows of [game], as the bloc maps it, with the board
  /// marking the last move.
  GameViewState screenOf(
    GameState game, {
    TurnPhase phase = const TurnPhase.awaitingPlacement(),
    Move? lastMove,
    bool canUndo = false,
    bool canRedo = false,
    Opponent opponent = const FriendOpponent(),
  }) {
    return const GameViewStateMapper().map(
      game: game,
      opponent: opponent,
      lastMove: lastMove,
      phase: phase,
      highlightLastMove: true,
      canUndo: canUndo,
      canRedo: canRedo,
    );
  }

  GameViewState placing(GameState game) => screenOf(game);

  /// A tap on [square], as the screen sends it.
  SquareTapped tap(Position square) {
    return SquareTapped(row: square.row, col: square.col);
  }

  /// The state after [move], as the engine plays it.
  GameState after(GameState state, Move move) =>
      switch (rules.apply(state, move)) {
        Ok(:final value) => value,
        Err(:final error) => throw StateError('Illegal test move: $error'),
      };

  /// Rule sheet Fig. 4: a die on the top centre square can capture three
  /// ways, using the 1s either side and the 5 below.
  final figure4 = stateFromAscii('''
    .  w1 .  w1 .
    .  .  b5 .  .
    .  .  .  .  .
    .  .  .  .  .
    .  .  .  .  .
  ''', toMove: Player.black);
  final topOptions = [
    for (final move in rules.legalMoves(figure4))
      if (move.position == top) move.captures,
  ];

  GameViewState choosing({
    Set<Position> selected = const {},
    int sum = 0,
    bool canConfirm = false,
  }) => screenOf(
    figure4,
    phase: TurnPhase.choosingCapture(
      target: top,
      options: topOptions,
      selected: selected,
      selectedSum: sum,
      canConfirm: canConfirm,
    ),
  );

  group('GameBloc', () {
    test('R1: starts a new game with Black to place a die', () {
      expect(build().state, placing(rules.newGame()));
    });

    test('starts under the config it is given', () {
      const config = GameConfig(firstPlayer: Player.white);

      final bloc = createTestGameBloc(config: config);

      expect(bloc.state, placing(rules.newGame(config)));
    });

    blocTest<GameBloc, GameViewState>(
      'R7: a tap with no capture places a 1 and passes the turn',
      build: build,
      act: (bloc) => bloc.add(tap(center)),
      expect: () => [
        screenOf(
          after(rules.newGame(), Move(center)),
          lastMove: Move(center),
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'R2: a tap on an occupied square does nothing',
      build: () => buildAt(figure4),
      act: (bloc) => bloc.add(tap(left)),
      expect: () => <GameViewState>[],
    );

    final oneCapture = stateFromAscii('''
      .  .  .  .  .
      .  .  w2 .  .
      .  b3 .  .  .
      .  .  .  .  .
      .  .  .  .  .
    ''', toMove: Player.white);
    final captureBoth = Move(
      center,
      captures: {const Position(1, 2), const Position(2, 1)},
    );

    blocTest<GameBloc, GameViewState>(
      'R5: a tap with exactly one capture plays it at once',
      build: () => buildAt(oneCapture),
      act: (bloc) => bloc.add(tap(center)),
      expect: () => [
        screenOf(
          after(oneCapture, captureBoth),
          lastMove: captureBoth,
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'R5: a tap with several captures lets the player choose',
      build: () => buildAt(figure4),
      act: (bloc) => bloc.add(tap(top)),
      expect: () => [choosing()],
      verify: (_) => expect(topOptions, hasLength(3)),
    );

    blocTest<GameBloc, GameViewState>(
      'picking dice updates the sum and whether the capture is valid',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(tap(top))
        ..add(tap(left))
        ..add(tap(right)),
      skip: 1,
      expect: () => [
        choosing(selected: {left}, sum: 1),
        choosing(selected: {left, right}, sum: 2, canConfirm: true),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'tapping a picked die again takes it out',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(tap(top))
        ..add(tap(below))
        ..add(tap(below)),
      skip: 2,
      expect: () => [choosing()],
    );

    blocTest<GameBloc, GameViewState>(
      'dice outside every capture option cannot be picked',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(tap(top))
        ..add(tap(top))
        ..add(tap(const Position(4, 4))),
      skip: 1,
      expect: () => <GameViewState>[],
    );

    blocTest<GameBloc, GameViewState>(
      'R6: confirming plays the chosen capture',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(tap(top))
        ..add(tap(left))
        ..add(tap(right))
        ..add(const CaptureConfirmed()),
      skip: 3,
      expect: () => [
        screenOf(
          after(figure4, Move(top, captures: {left, right})),
          lastMove: Move(top, captures: {left, right}),
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'confirming does nothing until the picked dice are an option',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(tap(top))
        ..add(tap(left))
        ..add(const CaptureConfirmed()),
      skip: 2,
      expect: () => <GameViewState>[],
    );

    blocTest<GameBloc, GameViewState>(
      'cancelling goes back to placing, with the board unchanged',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(tap(top))
        ..add(tap(left))
        ..add(const CaptureCancelled()),
      skip: 2,
      expect: () => [placing(figure4)],
    );

    blocTest<GameBloc, GameViewState>(
      'confirm and cancel do nothing while placing',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(const CaptureConfirmed())
        ..add(const CaptureCancelled()),
      expect: () => <GameViewState>[],
    );

    final lastSquare = stateFromAscii('''
      b6 w6 b6
      w6 .  w6
      b6 w6 b6
    ''', toMove: Player.black);
    const blackWins = Finished(
      winner: Player.black,
      blackDice: 5,
      whiteDice: 4,
    );

    blocTest<GameBloc, GameViewState>(
      'R8: filling the last square ends the game',
      build: () => buildAt(lastSquare),
      act: (bloc) => bloc.add(tap(const Position(1, 1))),
      expect: () => [
        screenOf(
          after(lastSquare, Move(const Position(1, 1))),
          phase: const TurnPhase.gameEnded(blackWins),
          lastMove: Move(const Position(1, 1)),
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'taps after the game ended do nothing',
      build: () => buildAt(lastSquare),
      act: (bloc) => bloc
        ..add(tap(const Position(1, 1)))
        ..add(tap(const Position(1, 1))),
      skip: 1,
      expect: () => <GameViewState>[],
    );

    blocTest<GameBloc, GameViewState>(
      'starting a new game drops the current one',
      build: () => buildAt(figure4),
      act: (bloc) => bloc
        ..add(tap(top))
        ..add(tap(left))
        ..add(
          const GameStarted(
            opponent: FriendOpponent(),
            config: GameConfig(boardSize: 3),
          ),
        ),
      skip: 2,
      expect: () => [placing(rules.newGame(const GameConfig(boardSize: 3)))],
    );

    blocTest<GameBloc, GameViewState>(
      'restarting keeps the rules of the game on screen',
      build: () => createTestGameBloc(config: const GameConfig(boardSize: 3)),
      act: (bloc) => bloc
        ..add(tap(const Position(1, 1)))
        ..add(const GameRestarted()),
      skip: 1,
      expect: () => [placing(rules.newGame(const GameConfig(boardSize: 3)))],
    );
  });

  group('GameBloc saving and history', () {
    late InMemoryGameRepository repository;
    const friend = FriendOpponent();
    final savedNewGame = (record: GameRecord(), opponent: friend);
    final played = screenOf(
      after(rules.newGame(), Move(center)),
      lastMove: Move(center),
      canUndo: true,
    );
    final undone = placing(rules.newGame()).copyWith(canRedo: true);

    setUp(() => repository = InMemoryGameRepository());

    GameBloc buildSaving() => createTestGameBloc(repository: repository);

    /// Lets the bloc finish the events it was given, storage included.
    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('saves the game after every move', () async {
      final bloc = buildSaving()
        ..add(tap(center))
        ..add(tap(top));
      await settle();

      final record = GameRecord(moves: [Move(center), Move(top)]);
      expect(await repository.load(), (record: record, opponent: friend));
      await bloc.close();
    });

    test(
      'keeps playing when the game cannot be saved, and reports it',
      () async {
        final reasons = <String?>[];
        final bloc = createTestGameBloc(
          repository: BestEffortGameRepository(
            gameRepository: FailingGameRepository(Exception('Storage is full')),
            errorReporter: (_, _, {reason}) => reasons.add(reason),
          ),
        )..add(tap(center));
        await settle();

        expect(bloc.state, played);
        expect(reasons, ['saving the game']);
        await bloc.close();
      },
    );

    blocTest<GameBloc, GameViewState>(
      'undo takes back the last move, and redo plays it again',
      build: build,
      act: (bloc) => bloc
        ..add(tap(center))
        ..add(const UndoRequested())
        ..add(const RedoRequested()),
      expect: () => [played, undone, played],
    );

    blocTest<GameBloc, GameViewState>(
      'a new move clears the moves taken back',
      build: build,
      act: (bloc) => bloc
        ..add(tap(center))
        ..add(const UndoRequested())
        ..add(tap(top)),
      expect: () => [
        played,
        undone,
        screenOf(
          after(rules.newGame(), Move(top)),
          lastMove: Move(top),
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'R8: a finished game cannot be undone',
      build: () => createTestGameBloc(config: const GameConfig(boardSize: 1)),
      act: (bloc) => bloc
        ..add(tap(const Position(0, 0)))
        ..add(const UndoRequested()),
      skip: 1,
      expect: () => <GameViewState>[],
      verify: (bloc) {
        expect(bloc.state.headline, isA<PlayerWonHeadline>());
        expect(bloc.state.canUndo, isFalse);
      },
    );

    blocTest<GameBloc, GameViewState>(
      'undo and redo do nothing with no move to take back or play again',
      build: build,
      act: (bloc) => bloc
        ..add(const UndoRequested())
        ..add(const RedoRequested()),
      expect: () => <GameViewState>[],
    );

    test('picks up the saved game', () async {
      final record = GameRecord(moves: [Move(center), Move(top)]);
      await repository.save((record: record, opponent: friend));
      final first = after(rules.newGame(), Move(center));
      final second = after(first, Move(top));

      final bloc = buildSaving()..add(const GameResumed());
      await settle();

      expect(
        bloc.state,
        screenOf(
          second,
          lastMove: Move(top),
          canUndo: true,
        ),
      );
      await bloc.close();
    });

    test('starts and saves a new game when there is none to resume', () async {
      final bloc = buildSaving()..add(const GameResumed());
      await settle();

      expect(bloc.state, placing(rules.newGame()));
      expect(await repository.load(), savedNewGame);
      await bloc.close();
    });

    test('starting a game replaces the saved one', () async {
      final record = GameRecord(moves: [Move(center)]);
      await repository.save((record: record, opponent: friend));

      final bloc = buildSaving()..add(const GameStarted(opponent: friend));
      await settle();

      expect(await repository.load(), savedNewGame);
      await bloc.close();
    });
  });

  group('GameBloc against the computer', () {
    late InMemoryGameRepository repository;
    const blackComputer = ComputerOpponent(
      difficulty: Difficulty.easy,
      player: Player.black,
    );
    const whiteComputer = ComputerOpponent(
      difficulty: Difficulty.easy,
      player: Player.white,
    );
    final start = rules.newGame();
    final afterCenter = after(start, Move(center));
    final reply = rules.legalMoves(afterCenter).first;
    final waiting = screenOf(start, opponent: whiteComputer);
    final thinking = screenOf(
      afterCenter,
      phase: const TurnPhase.computerThinking(),
      lastMove: Move(center),
      opponent: whiteComputer,
    );
    final replied = screenOf(
      after(afterCenter, reply),
      lastMove: reply,
      canUndo: true,
      opponent: whiteComputer,
    );

    setUp(() => repository = InMemoryGameRepository());

    /// Saves a new game against [computer], for the bloc to resume. The test
    /// bloc's computer plays its first legal move.
    Future<void> saveGameAgainst(ComputerOpponent computer) {
      return repository.save((record: GameRecord(), opponent: computer));
    }

    GameBloc buildResuming() => createTestGameBloc(repository: repository);

    blocTest<GameBloc, GameViewState>(
      'plays first when it plays Black, thinking meanwhile',
      setUp: () => saveGameAgainst(blackComputer),
      build: buildResuming,
      act: (bloc) => bloc.add(const GameResumed()),
      expect: () {
        final opening = rules.legalMoves(start).first;
        return [
          screenOf(
            start,
            phase: const TurnPhase.computerThinking(),
            opponent: blackComputer,
          ),
          screenOf(
            after(start, opening),
            lastMove: opening,
            opponent: blackComputer,
          ),
        ];
      },
    );

    blocTest<GameBloc, GameViewState>(
      "replies to the person's move, and saves both",
      setUp: () => saveGameAgainst(whiteComputer),
      build: buildResuming,
      act: (bloc) => bloc
        ..add(const GameResumed())
        ..add(tap(center)),
      // Resuming a game with no moves emits the starting position again:
      // a bloc's first emission is never skipped as a duplicate.
      expect: () => [waiting, thinking, replied],
      verify: (_) async {
        final saved = await repository.load();
        expect(saved?.record.moves, [Move(center), reply]);
      },
    );

    blocTest<GameBloc, GameViewState>(
      "undo takes back the reply and the person's move; redo plays both",
      setUp: () => saveGameAgainst(whiteComputer),
      build: buildResuming,
      act: (bloc) => bloc
        ..add(const GameResumed())
        ..add(tap(center))
        ..add(const UndoRequested())
        ..add(const RedoRequested()),
      expect: () => [
        waiting,
        thinking,
        replied,
        waiting.copyWith(canRedo: true),
        replied,
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'restarting keeps playing the computer',
      setUp: () => saveGameAgainst(whiteComputer),
      build: buildResuming,
      act: (bloc) => bloc
        ..add(const GameResumed())
        ..add(tap(center))
        ..add(const GameRestarted()),
      expect: () => [waiting, thinking, replied, waiting],
      verify: (_) async {
        final saved = await repository.load();
        expect(saved?.opponent, whiteComputer);
        expect(saved?.record.moves, isEmpty);
      },
    );

    test('drops its move when the screen closes while it thinks', () async {
      // The computer thinks until the test lets it finish.
      final thought = Completer<void>();
      Future<R> slowRunner<M, R>(
        FutureOr<R> Function(M message) callback,
        M message,
      ) async {
        await thought.future;
        return callback(message);
      }

      await saveGameAgainst(blackComputer);
      final closing = createTestGameBloc(
        repository: repository,
        backgroundRunner: slowRunner,
      )..add(const GameResumed());
      await pumpEventQueue();
      // Leaving the screen closes its bloc without waiting, as
      // `BlocProvider` does.
      unawaited(closing.close());

      // The player starts another game, which is saved.
      final next = createTestGameBloc(repository: repository)
        ..add(const GameStarted(opponent: FriendOpponent()));
      await pumpEventQueue();
      thought.complete();
      await pumpEventQueue();

      final saved = await repository.load();
      expect(saved?.opponent, const FriendOpponent());
      expect(saved?.record.moves, isEmpty);
      await next.close();
    });

    blocTest<GameBloc, GameViewState>(
      'reports an agent that breaks the rules, and saves nothing',
      setUp: () => saveGameAgainst(blackComputer),
      build: () => createTestGameBloc(
        repository: repository,
        agentFactory: (_) => _OffBoardAgent(),
      ),
      act: (bloc) => bloc.add(const GameResumed()),
      expect: () => [
        screenOf(
          start,
          phase: const TurnPhase.computerThinking(),
          opponent: blackComputer,
        ),
      ],
      errors: () => [isStateError],
      verify: (_) async {
        final saved = await repository.load();
        expect(saved?.record.moves, isEmpty);
      },
    );
  });
}

/// An agent that always plays off the board, which the rules refuse.
final class _OffBoardAgent implements GameAgent {
  @override
  Move chooseMove(GameState state) => Move(const Position(9, 9));
}
