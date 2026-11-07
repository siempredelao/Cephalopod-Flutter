import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_bloc_factory.dart';

void main() {
  final rules = CephalopodRules();
  const center = Position(2, 2);
  const top = Position(0, 2);
  const left = Position(0, 1);
  const right = Position(0, 3);
  const below = Position(1, 2);

  GameBloc build() => createTestGameBloc();

  GameViewState placing(GameState game) =>
      GameViewState(game: game, phase: const TurnPhase.awaitingPlacement());

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
  }) => placing(figure4).copyWith(
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
      act: (bloc) => bloc.add(const SquareTapped(center)),
      expect: () => [
        GameViewState(
          game: after(rules.newGame(), Move(center)),
          phase: const TurnPhase.awaitingPlacement(),
          lastMove: Move(center),
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'R2: a tap on an occupied square does nothing',
      build: build,
      seed: () => placing(figure4),
      act: (bloc) => bloc.add(const SquareTapped(left)),
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
      build: build,
      seed: () => placing(oneCapture),
      act: (bloc) => bloc.add(const SquareTapped(center)),
      expect: () => [
        GameViewState(
          game: after(oneCapture, captureBoth),
          phase: const TurnPhase.awaitingPlacement(),
          lastMove: captureBoth,
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'R5: a tap with several captures lets the player choose',
      build: build,
      seed: () => placing(figure4),
      act: (bloc) => bloc.add(const SquareTapped(top)),
      expect: () => [choosing()],
      verify: (_) => expect(topOptions, hasLength(3)),
    );

    blocTest<GameBloc, GameViewState>(
      'picking dice updates the sum and whether the capture is valid',
      build: build,
      seed: choosing,
      act: (bloc) => bloc
        ..add(const SquareTapped(left))
        ..add(const SquareTapped(right)),
      expect: () => [
        choosing(selected: {left}, sum: 1),
        choosing(selected: {left, right}, sum: 2, canConfirm: true),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'tapping a picked die again takes it out',
      build: build,
      seed: () => choosing(selected: {below}, sum: 5),
      act: (bloc) => bloc.add(const SquareTapped(below)),
      expect: () => [choosing()],
    );

    blocTest<GameBloc, GameViewState>(
      'dice outside every capture option cannot be picked',
      build: build,
      seed: choosing,
      act: (bloc) => bloc
        ..add(const SquareTapped(top))
        ..add(const SquareTapped(Position(4, 4))),
      expect: () => <GameViewState>[],
    );

    blocTest<GameBloc, GameViewState>(
      'R6: confirming plays the chosen capture',
      build: build,
      seed: () => choosing(selected: {left, right}, sum: 2, canConfirm: true),
      act: (bloc) => bloc.add(const CaptureConfirmed()),
      expect: () => [
        GameViewState(
          game: after(figure4, Move(top, captures: {left, right})),
          phase: const TurnPhase.awaitingPlacement(),
          lastMove: Move(top, captures: {left, right}),
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'confirming does nothing until the picked dice are an option',
      build: build,
      seed: () => choosing(selected: {left}, sum: 1),
      act: (bloc) => bloc.add(const CaptureConfirmed()),
      expect: () => <GameViewState>[],
    );

    blocTest<GameBloc, GameViewState>(
      'cancelling goes back to placing, with the board unchanged',
      build: build,
      seed: () => choosing(selected: {left}, sum: 1),
      act: (bloc) => bloc.add(const CaptureCancelled()),
      expect: () => [placing(figure4)],
    );

    blocTest<GameBloc, GameViewState>(
      'confirm and cancel do nothing while placing',
      build: build,
      seed: () => placing(figure4),
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
      build: build,
      seed: () => placing(lastSquare),
      act: (bloc) => bloc.add(const SquareTapped(Position(1, 1))),
      expect: () => [
        GameViewState(
          game: after(lastSquare, Move(const Position(1, 1))),
          phase: const TurnPhase.gameEnded(blackWins),
          lastMove: Move(const Position(1, 1)),
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'taps after the game ended do nothing',
      build: build,
      seed: () => GameViewState(
        game: after(lastSquare, Move(const Position(1, 1))),
        phase: const TurnPhase.gameEnded(blackWins),
      ),
      act: (bloc) => bloc.add(const SquareTapped(Position(1, 1))),
      expect: () => <GameViewState>[],
    );

    blocTest<GameBloc, GameViewState>(
      'starting a new game drops the current one',
      build: build,
      seed: () => choosing(selected: {left}, sum: 1),
      act: (bloc) => bloc.add(
        const GameStarted(
          opponent: FriendOpponent(),
          config: GameConfig(boardSize: 3),
        ),
      ),
      expect: () => [placing(rules.newGame(const GameConfig(boardSize: 3)))],
    );

    blocTest<GameBloc, GameViewState>(
      'restarting keeps the rules of the game on screen',
      build: () => createTestGameBloc(config: const GameConfig(boardSize: 3)),
      act: (bloc) => bloc
        ..add(const SquareTapped(Position(1, 1)))
        ..add(const GameRestarted()),
      skip: 1,
      expect: () => [placing(rules.newGame(const GameConfig(boardSize: 3)))],
    );
  });

  group('GameBloc saving and history', () {
    late InMemoryGameRepository repository;
    const friend = FriendOpponent();
    final savedNewGame = (record: GameRecord(), opponent: friend);
    final played = GameViewState(
      game: after(rules.newGame(), Move(center)),
      phase: const TurnPhase.awaitingPlacement(),
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
        ..add(const SquareTapped(center))
        ..add(const SquareTapped(top));
      await settle();

      final record = GameRecord(moves: [Move(center), Move(top)]);
      expect(await repository.load(), (record: record, opponent: friend));
      await bloc.close();
    });

    blocTest<GameBloc, GameViewState>(
      'undo takes back the last move, and redo plays it again',
      build: build,
      act: (bloc) => bloc
        ..add(const SquareTapped(center))
        ..add(const UndoRequested())
        ..add(const RedoRequested()),
      expect: () => [played, undone, played],
    );

    blocTest<GameBloc, GameViewState>(
      'a new move clears the moves taken back',
      build: build,
      act: (bloc) => bloc
        ..add(const SquareTapped(center))
        ..add(const UndoRequested())
        ..add(const SquareTapped(top)),
      expect: () => [
        played,
        undone,
        GameViewState(
          game: after(rules.newGame(), Move(top)),
          phase: const TurnPhase.awaitingPlacement(),
          lastMove: Move(top),
          canUndo: true,
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'R8: a finished game cannot be undone',
      build: () => createTestGameBloc(config: const GameConfig(boardSize: 1)),
      act: (bloc) => bloc
        ..add(const SquareTapped(Position(0, 0)))
        ..add(const UndoRequested()),
      skip: 1,
      expect: () => <GameViewState>[],
      verify: (bloc) {
        expect(bloc.state.phase, isA<GameEnded>());
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
        GameViewState(
          game: second,
          phase: const TurnPhase.awaitingPlacement(),
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
    final waiting = placing(start).copyWith(opponent: whiteComputer);
    final thinking = GameViewState(
      game: afterCenter,
      phase: const TurnPhase.computerThinking(),
      lastMove: Move(center),
      opponent: whiteComputer,
    );
    final replied = GameViewState(
      game: after(afterCenter, reply),
      phase: const TurnPhase.awaitingPlacement(),
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
          GameViewState(
            game: start,
            phase: const TurnPhase.computerThinking(),
            opponent: blackComputer,
          ),
          GameViewState(
            game: after(start, opening),
            phase: const TurnPhase.awaitingPlacement(),
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
        ..add(const SquareTapped(center)),
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
        ..add(const SquareTapped(center))
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
        ..add(const SquareTapped(center))
        ..add(const GameRestarted()),
      expect: () => [waiting, thinking, replied, waiting],
      verify: (_) async {
        final saved = await repository.load();
        expect(saved?.opponent, whiteComputer);
        expect(saved?.record.moves, isEmpty);
      },
    );
  });
}
