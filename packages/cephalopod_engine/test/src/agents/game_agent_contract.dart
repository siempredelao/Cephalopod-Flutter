import 'dart:isolate';
import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

import '../../helpers/result.dart';

/// Builds the agent under test from the rules it sees and its source of
/// randomness.
typedef AgentFactory = GameAgent Function(
  MoveGenerator moveGenerator,
  Random random,
);

/// The tests every [GameAgent] passes, whatever its strategy, so the app can
/// swap one difficulty for another (docs/architecture.md, Liskov
/// substitution). Call it from the agent's own test file, inside `main`.
///
/// The agent plays [games] seeded games against itself on the standard board.
/// A stronger, slower agent can ask for fewer.
void gameAgentContract(AgentFactory createAgent, {int games = 10}) {
  final rules = CephalopodRules();

  /// The moves [agent] plays against itself from a new game under [config],
  /// checking each one is legal. A game ends within 300 moves on the standard
  /// board (see the property test), so more means the agent is stuck.
  List<Move> selfPlay(GameAgent agent, GameConfig config) {
    var state = rules.newGame(config);
    final played = <Move>[];
    while (state.status is InProgress) {
      final move = agent.chooseMove(state);
      expect(rules.legalMoves(state), contains(move));
      state = rules.apply(state, move).valueOrFail;
      played.add(move);
      if (played.length > 300) fail('The game did not end');
    }
    return played;
  }

  group('GameAgent contract', () {
    test('plays only legal moves, for both players, to the end', () {
      for (var seed = 0; seed < games; seed++) {
        final agent = createAgent(rules, Random(seed));

        expect(selfPlay(agent, GameConfig.standard), isNotEmpty);
      }
    });

    test('plays a game on any board the rules allow', () {
      const small = GameConfig(boardSize: 3, firstPlayer: Player.white);

      expect(selfPlay(createAgent(rules, Random(0)), small), isNotEmpty);
    });

    test('chooses the same moves again with the same seed', () {
      final first = createAgent(rules, Random(42));
      final second = createAgent(rules, Random(42));

      expect(
        selfPlay(second, GameConfig.standard),
        selfPlay(first, GameConfig.standard),
      );
    });

    test('plays the only legal move when there is one', () {
      // Every pair of neighbours sums to 8, so the centre takes a plain 1.
      final state = stateFromAscii('''
        b1 w4 b1
        b4 .  w4
        b1 w4 b1
      ''', toMove: Player.white);
      final agent = createAgent(rules, Random(0));

      expect(agent.chooseMove(state), rules.legalMoves(state).single);
    });

    test('chooses on another isolate the move it chooses here', () async {
      // Two agents with the same seed, so each starts from the same random
      // state: one chooses here, the other on another isolate.
      final state = rules.newGame();
      final here = createAgent(rules, Random(7)).chooseMove(state);

      final there = await _chooseOnAnotherIsolate(
        createAgent(rules, Random(7)),
        state,
      );

      expect(there, here);
    });

    test('throws an ArgumentError when the game is over', () {
      final finished = stateFromAscii('''
        b1 w1 b1
        w1 b1 w1
        b1 w1 b1
      ''', toMove: Player.white);
      final agent = createAgent(rules, Random(0));

      expect(() => agent.chooseMove(finished), throwsArgumentError);
    });
  });
}

/// [agent]'s move in [state], chosen on another isolate, as the app runs it
/// with Flutter's `compute`.
///
/// The isolate gets a copy of the agent and the position, and of nothing
/// else: this function's closure holds only those two. An agent that holds
/// something that cannot be copied, such as an open port or a native
/// resource, fails here instead of on a phone.
Future<Move> _chooseOnAnotherIsolate(GameAgent agent, GameState state) {
  return Isolate.run(() => agent.chooseMove(state));
}
