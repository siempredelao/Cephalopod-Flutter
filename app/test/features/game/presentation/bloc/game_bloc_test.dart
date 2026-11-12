import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/data/saved_game_json_codec.dart';
import 'package:cephalopod/features/game/data/shared_preferences_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/countdown_timer.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/hint_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/played_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../../helpers/counting_game_repository.dart';
import '../../../../helpers/failing_shared_preferences.dart';
import '../../../../helpers/fake_sound_effects.dart';
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
    PlayedMove? playedMove,
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
      playedMove: playedMove,
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
          playedMove: (
            move: Move(center),
            byComputer: false,
            captured: const {},
          ),
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
          playedMove: (
            move: captureBoth,
            byComputer: false,
            captured: {
              for (final square in captureBoth.captures)
                square: oneCapture.board.dice[square]!,
            },
          ),
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
          playedMove: (
            move: Move(top, captures: {left, right}),
            byComputer: false,
            captured: {
              left: figure4.board.dice[left]!,
              right: figure4.board.dice[right]!,
            },
          ),
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
          playedMove: (
            move: Move(const Position(1, 1)),
            byComputer: false,
            captured: const {},
          ),
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
      playedMove: (move: Move(center), byComputer: false, captured: const {}),
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
        SharedPreferencesAsyncPlatform.instance = FailingSharedPreferences();
        final bloc = createTestGameBloc(
          repository: SharedPreferencesGameRepository(
            sharedPreferencesAsync: SharedPreferencesAsync(),
            savedGameJsonCodec: SavedGameJsonCodec(),
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
      expect: () => [
        played,
        undone,
        // The move is back, but it was not just played.
        played.copyWith(playedMove: null),
      ],
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
          playedMove: (move: Move(top), byComputer: false, captured: const {}),
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

  group('GameBloc after a move', () {
    const computer = ComputerOpponent(
      difficulty: Difficulty.easy,
      player: Player.white,
    );
    final afterCenter = after(rules.newGame(), Move(center));
    final afterTop = after(afterCenter, Move(top));
    final centerPlayed = screenOf(
      afterCenter,
      lastMove: Move(center),
      playedMove: (move: Move(center), byComputer: false, captured: const {}),
      canUndo: true,
    );
    late _ManualCountdown countdown;

    setUp(() => countdown = _ManualCountdown());

    GameBloc buildCounting() => createTestGameBloc(moveCountdown: countdown);

    /// Lets the bloc finish the events it was given.
    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('starts the countdown after a move', () async {
      final bloc = buildCounting()..add(tap(center));
      await settle();

      expect(countdown.isActive, isTrue);
      await bloc.close();
    });

    test('starts it for as long as the move captured dice ask', () async {
      final bloc =
          createTestGameBloc(
              position: figure4,
              moveCountdown: countdown,
              settleDurationFor: (captures) => Duration(seconds: captures),
            )
            ..add(tap(top))
            ..add(tap(left))
            ..add(tap(right))
            ..add(const CaptureConfirmed());
      await settle();

      expect(countdown.started, [const Duration(seconds: 2)]);
      await bloc.close();
    });

    test('starts it with no wait for a move that captures nothing', () async {
      final bloc = createTestGameBloc(
        moveCountdown: countdown,
        settleDurationFor: (captures) => Duration(seconds: captures),
      )..add(tap(center));
      await settle();

      expect(countdown.started, [Duration.zero]);
      await bloc.close();
    });

    test('ignores taps until the countdown ends', () async {
      final bloc = buildCounting()
        ..add(tap(center))
        ..add(tap(top));
      await settle();

      expect(bloc.state, centerPlayed);

      countdown.cancel();
      bloc.add(tap(top));
      await settle();

      expect(
        bloc.state,
        screenOf(
          afterTop,
          lastMove: Move(top),
          playedMove: (move: Move(top), byComputer: false, captured: const {}),
          canUndo: true,
        ),
      );
      await bloc.close();
    });

    test('lets the computer reply only once the countdown ends', () async {
      final bloc = buildCounting()
        ..add(const GameStarted(opponent: computer))
        ..add(tap(center));
      await settle();

      expect(bloc.state.canTap, isFalse);
      expect(bloc.state.playedMove?.computer, isNull);

      countdown.cancel();
      await bloc.stream.firstWhere(
        (state) => state.playedMove?.computer != null,
      );
      await bloc.close();
    });

    test('ends the countdown on undo, so a tap after it works', () async {
      final bloc = buildCounting()
        ..add(tap(center))
        ..add(const UndoRequested());
      await settle();

      expect(countdown.isActive, isFalse);
      expect(bloc.state, placing(rules.newGame()).copyWith(canRedo: true));

      bloc.add(tap(center));
      await settle();

      expect(bloc.state, centerPlayed);
      await bloc.close();
    });

    test('ends the countdown on a new game', () async {
      final bloc = buildCounting()
        ..add(tap(center))
        ..add(const GameRestarted());
      await settle();

      expect(countdown.isActive, isFalse);
      await bloc.close();
    });

    test('ends the countdown when it closes', () async {
      final bloc = buildCounting()..add(tap(center));
      await settle();

      await bloc.close();

      expect(countdown.isActive, isFalse);
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
      playedMove: (move: Move(center), byComputer: false, captured: const {}),
      opponent: whiteComputer,
    );
    final replied = screenOf(
      after(afterCenter, reply),
      lastMove: reply,
      playedMove: (move: reply, byComputer: true, captured: const {}),
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
            playedMove: (move: opening, byComputer: true, captured: const {}),
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
        // Both moves are back, but they were not just played.
        replied.copyWith(playedMove: null),
      ],
    );

    test('one undo saves once, for both moves it takes back', () async {
      final counting = CountingGameRepository();
      await counting.save((record: GameRecord(), opponent: whiteComputer));
      final bloc = createTestGameBloc(repository: counting)
        ..add(const GameResumed())
        ..add(tap(center));
      await pumpEventQueue();
      final savesBeforeUndo = counting.saves;

      bloc.add(const UndoRequested());
      await pumpEventQueue();

      expect(bloc.state, waiting.copyWith(canRedo: true));
      expect(counting.saves - savesBeforeUndo, 1);
      expect((await counting.load())?.record.moves, isEmpty);
      await bloc.close();
    });

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

  group('GameBloc sounds', () {
    late FakeSoundEffects sounds;

    setUp(() => sounds = FakeSoundEffects());

    /// White to move, with a 2 and a 3 beside the centre: a die there
    /// captures both.
    final beforeCapture = stateFromAscii('''
      .  .  .  .  .
      .  .  w2 .  .
      .  b3 .  .  .
      .  .  .  .  .
      .  .  .  .  .
    ''', toMove: Player.white);

    blocTest<GameBloc, GameViewState>(
      'pops when a move captures',
      build: () =>
          createTestGameBloc(position: beforeCapture, soundEffects: sounds),
      act: (bloc) => bloc.add(tap(center)),
      verify: (_) => expect(sounds.played, ['capture']),
    );

    blocTest<GameBloc, GameViewState>(
      'keeps quiet for a move that captures nothing',
      build: () => createTestGameBloc(soundEffects: sounds),
      act: (bloc) => bloc.add(tap(center)),
      verify: (_) => expect(sounds.played, isEmpty),
    );

    blocTest<GameBloc, GameViewState>(
      'pops once for a capture, though the screen changes after it',
      build: () =>
          createTestGameBloc(position: beforeCapture, soundEffects: sounds),
      act: (bloc) => bloc
        ..add(tap(center))
        ..add(const HintRequested()),
      verify: (_) => expect(sounds.played, ['capture']),
    );

    blocTest<GameBloc, GameViewState>(
      'keeps quiet when a capture is taken back or played again',
      build: () =>
          createTestGameBloc(position: beforeCapture, soundEffects: sounds),
      act: (bloc) => bloc
        ..add(tap(center))
        ..add(const UndoRequested())
        ..add(const RedoRequested()),
      verify: (_) => expect(sounds.played, ['capture']),
    );

    test("pops when the computer's move captures", () async {
      // On a 3 × 3 board, Black and White place a 1 beside the top left
      // corner. The computer, Black, plays its first legal move: the
      // corner, capturing both.
      final repository = InMemoryGameRepository();
      await repository.save((
        record: GameRecord(
          config: const GameConfig(boardSize: 3),
          moves: [Move(const Position(0, 1)), Move(const Position(1, 0))],
        ),
        opponent: const ComputerOpponent(
          difficulty: Difficulty.easy,
          player: Player.black,
        ),
      ));
      final bloc = createTestGameBloc(
        repository: repository,
        soundEffects: sounds,
      )..add(const GameResumed());
      await pumpEventQueue();

      expect(bloc.state.playedMove?.computer, isNotNull);
      expect(bloc.state.playedMove?.captured, hasLength(2));
      expect(sounds.played, ['capture']);
      await bloc.close();
    });
  });

  group('GameBloc win sound', () {
    late FakeSoundEffects sounds;
    late InMemoryGameRepository repository;
    const oneSquare = GameConfig(boardSize: 1);

    setUp(() {
      sounds = FakeSoundEffects();
      repository = InMemoryGameRepository();
    });

    GameBloc buildOnOneSquare() => createTestGameBloc(
      config: oneSquare,
      repository: repository,
      soundEffects: sounds,
    );

    blocTest<GameBloc, GameViewState>(
      'chimes when the move fills the board in a game between two people',
      build: buildOnOneSquare,
      act: (bloc) => bloc.add(tap(const Position(0, 0))),
      verify: (_) => expect(sounds.played, ['win']),
    );

    blocTest<GameBloc, GameViewState>(
      'keeps quiet when the game ends in a win taken back and played again',
      build: buildOnOneSquare,
      act: (bloc) => bloc
        ..add(tap(const Position(0, 0)))
        ..add(const UndoRequested())
        ..add(const RedoRequested()),
      verify: (_) => expect(sounds.played, ['win']),
    );

    blocTest<GameBloc, GameViewState>(
      'keeps quiet when the computer wins',
      // The computer plays Black, which moves first, and fills the board.
      setUp: () => repository.save((
        record: GameRecord(config: oneSquare),
        opponent: const ComputerOpponent(
          difficulty: Difficulty.easy,
          player: Player.black,
        ),
      )),
      build: buildOnOneSquare,
      act: (bloc) => bloc.add(const GameResumed()),
      verify: (bloc) {
        expect(bloc.state.playedMove?.computer, isNotNull);
        expect(sounds.played, isEmpty);
      },
    );

    blocTest<GameBloc, GameViewState>(
      'keeps quiet when a game the player won is picked up again',
      setUp: () => repository.save((
        record: GameRecord(
          config: oneSquare,
          moves: [Move(const Position(0, 0))],
        ),
        opponent: const FriendOpponent(),
      )),
      build: buildOnOneSquare,
      act: (bloc) => bloc.add(const GameResumed()),
      verify: (bloc) {
        expect(bloc.state.headline, isA<PlayerWonHeadline>());
        expect(sounds.played, isEmpty);
      },
    );
  });

  group('GameBloc after a game-ending move', () {
    test('celebrates the move that fills the board', () async {
      final bloc = createTestGameBloc(config: const GameConfig(boardSize: 1))
        ..add(tap(const Position(0, 0)));
      await pumpEventQueue();

      expect(bloc.state.playedMove?.celebrate, isTrue);
      await bloc.close();
    });
  });

  group('GameBloc hints', () {
    final newGame = rules.newGame();
    // The test agents play, and suggest, the first legal move.
    final suggested = rules.legalMoves(newGame).first;

    /// The screen of [game] while a die is to be placed, with [hint].
    GameViewState hinting(GameState game, HintState hint) {
      return screenOf(game, phase: TurnPhase.awaitingPlacement(hint: hint));
    }

    final searching = hinting(newGame, const HintState.searching());
    final hinted = hinting(newGame, HintState.found(suggested));

    blocTest<GameBloc, GameViewState>(
      'says it is looking, then shows the suggested move',
      build: build,
      act: (bloc) => bloc.add(const HintRequested()),
      expect: () => [searching, hinted],
    );

    blocTest<GameBloc, GameViewState>(
      'clears the hint when the player places a die',
      build: build,
      act: (bloc) => bloc
        ..add(const HintRequested())
        ..add(tap(center)),
      expect: () => [
        searching,
        hinted,
        // The new phase starts without a hint.
        screenOf(
          after(newGame, Move(center)),
          lastMove: Move(center),
          playedMove: (
            move: Move(center),
            byComputer: false,
            captured: const {},
          ),
          canUndo: true,
        ),
      ],
    );

    final centreTaken = after(newGame, Move(center));
    blocTest<GameBloc, GameViewState>(
      'keeps the hint on a tap that places nothing',
      build: () => buildAt(centreTaken),
      act: (bloc) => bloc
        ..add(const HintRequested())
        // The centre is taken, so the tap changes nothing.
        ..add(tap(center)),
      expect: () => [
        hinting(centreTaken, const HintState.searching()),
        hinting(
          centreTaken,
          HintState.found(rules.legalMoves(centreTaken).first),
        ),
      ],
    );

    blocTest<GameBloc, GameViewState>(
      'clears the hint on undo',
      build: build,
      act: (bloc) => bloc
        ..add(tap(center))
        ..add(const HintRequested())
        ..add(const UndoRequested()),
      skip: 3,
      expect: () => [placing(newGame).copyWith(canRedo: true)],
    );

    blocTest<GameBloc, GameViewState>(
      'gives one hint at a time',
      build: build,
      act: (bloc) => bloc
        ..add(const HintRequested())
        ..add(const HintRequested()),
      expect: () => [searching, hinted],
    );

    blocTest<GameBloc, GameViewState>(
      'gives no hint once the game is over',
      build: () => createTestGameBloc(config: const GameConfig(boardSize: 1)),
      act: (bloc) => bloc
        ..add(tap(const Position(0, 0)))
        ..add(const HintRequested()),
      // The move that fills the board, and nothing after it.
      expect: () => [isA<GameViewState>()],
    );

    test('gives no hint while the computer thinks', () async {
      // The computer thinks for as long as the test runs.
      final bloc =
          createTestGameBloc(
              backgroundRunner: <M, R>(_, _) => Completer<R>().future,
            )
            ..add(
              const GameStarted(
                opponent: ComputerOpponent(
                  difficulty: Difficulty.easy,
                  player: Player.black,
                ),
              ),
            )
            ..add(const HintRequested());
      await pumpEventQueue();

      expect(bloc.state.headline, const HeadlineUi.computerToMove());
      expect(bloc.state.canHint, isFalse);
      // Leaving the screen closes its bloc without waiting, as
      // `BlocProvider` does.
      unawaited(bloc.close());
    });

    test('drops the hint when the screen closes during the search', () async {
      final search = Completer<Move>();
      final bloc = createTestGameBloc(
        backgroundRunner: <M, R>(_, _) => search.future as Future<R>,
      )..add(const HintRequested());
      await pumpEventQueue();
      expect(bloc.state, searching);

      final closing = bloc.close();
      search.complete(suggested);
      await closing;

      expect(bloc.state, searching);
    });

    test('waits for the last move to be seen before it looks', () async {
      final countdown = _ManualCountdown();
      final bloc = createTestGameBloc(moveCountdown: countdown)
        ..add(tap(center))
        ..add(const HintRequested());
      await pumpEventQueue();

      expect(bloc.state.headline, isNot(const HeadlineUi.lookingForHint()));
      expect(bloc.state.hint, isNull);

      countdown.cancel();
      await bloc.stream.firstWhere((state) => state.hint != null);
      await bloc.close();
    });
  });
}

/// An agent that always plays off the board, which the rules refuse.
final class _OffBoardAgent implements GameAgent {
  @override
  Move chooseMove(GameState state) => Move(const Position(9, 9));
}

/// A countdown that runs until a test ends it, with [cancel].
final class _ManualCountdown implements CountdownTimer {
  Completer<void>? _running;

  /// The length of each wait it was started with, in order.
  final List<Duration> started = [];

  @override
  bool get isActive => _running != null;

  @override
  Future<void> get done => _running?.future ?? Future<void>.value();

  @override
  void start(Duration duration) {
    started.add(duration);
    cancel();
    _running = Completer<void>();
  }

  @override
  void cancel() {
    final running = _running;
    _running = null;
    running?.complete();
  }
}
