import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rules = CephalopodRules();
  const center = Position(2, 2);
  const top = Position(0, 2);
  const left = Position(0, 1);
  const right = Position(0, 3);
  const below = Position(1, 2);

  GameBloc build() => GameBloc(rules: rules);

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

      final bloc = GameBloc(rules: rules, config: config);

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
      act: (bloc) => bloc.add(const GameStarted(GameConfig(boardSize: 3))),
      expect: () => [placing(rules.newGame(const GameConfig(boardSize: 3)))],
    );
  });
}
