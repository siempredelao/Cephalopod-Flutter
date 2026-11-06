import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

import '../../helpers/result.dart';

/// Builds the agent under test from the rules it sees and its source of
/// randomness.
typedef AgentFactory = GameAgent Function(MoveGenerator moves, Random random);

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
