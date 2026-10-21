import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

import '../../helpers/result.dart';

/// Plays seeded random games to the end and checks, after every move, the
/// properties that make Cephalopod well defined. Replaying each game's moves
/// must then rebuild the position it ended in.
///
/// The game always ends. A non-capturing move adds one die and 1 pip; a
/// capture keeps the pip total and removes at least one die net. The pip
/// total cannot pass 6 × 25 = 150, so there are at most 150 non-capturing
/// moves. Captures never outnumber them, because every die a capture removes
/// net was added by one of them. That bounds a game at 300 moves.
void main() {
  const games = 1000;
  const maxMoves = 300;
  final rules = CephalopodRules();
  final finder = CaptureFinder(geometry: BoardGeometry());

  int totalPips(Board board) => finder.pipSum(board, board.dice.keys);

  test('random games keep every invariant and always end', () {
    for (var seed = 0; seed < games; seed++) {
      final random = Random(seed);
      var state = rules.newGame();
      var moves = 0;
      final played = <Move>[];

      while (true) {
        final status = state.status;
        if (status is! InProgress) break;
        final where = 'seed $seed, move $moves';
        final legal = rules.legalMoves(state);
        expect(legal, isNotEmpty, reason: 'R2, $where');

        final move = legal[random.nextInt(legal.length)];
        final next = rules.apply(state, move).valueOrFail;
        final captured = move.captures.length;

        if (captured == 0) {
          expect(
            totalPips(next.board),
            totalPips(state.board) + 1,
            reason: where,
          );
          expect(
            next.board.dice.length,
            state.board.dice.length + 1,
            reason: where,
          );
        } else {
          expect(captured, greaterThanOrEqualTo(2), reason: 'R4, $where');
          expect(totalPips(next.board), totalPips(state.board), reason: where);
          expect(
            next.board.dice.length,
            state.board.dice.length - captured + 1,
            reason: 'R6, $where',
          );
        }
        final placed = next.board.dice[move.position];
        expect(placed?.owner, status.toMove, reason: 'R1, $where');
        expect(placed?.pips, inInclusiveRange(1, 6), reason: where);

        state = next;
        played.add(move);
        moves++;
        expect(moves, lessThanOrEqualTo(maxMoves), reason: 'seed $seed');
      }

      final status = state.status;
      if (status is! Finished) fail('Seed $seed ended without a winner');
      final winnerDice = status.winner == Player.black
          ? status.blackDice
          : status.whiteDice;
      expect(state.board.dice, hasLength(25), reason: 'R8, seed $seed');
      expect(winnerDice, greaterThan(25 - winnerDice), reason: 'seed $seed');

      final replayed = rules.replay(GameRecord(moves: played));
      expect(replayed.valueOrFail, state, reason: 'replay, seed $seed');
    }
  });
}
