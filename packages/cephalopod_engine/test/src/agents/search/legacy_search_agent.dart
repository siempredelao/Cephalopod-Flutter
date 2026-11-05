// Temporary: a frozen copy of SearchAgent from before it was split into
// NodeBudget, MoveRanker and SearchPass. The equivalence test plays both and
// expects identical moves. Both files are deleted once CI has run them.

import 'dart:math';

import 'package:cephalopod_engine/src/agents/apply_legal_move.dart';
import 'package:cephalopod_engine/src/agents/game_agent.dart';
import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/agents/position_evaluator.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/move.dart';
import 'package:cephalopod_engine/src/models/player.dart';
import 'package:collection/collection.dart';

/// SearchAgent as merged in #29, kept to compare against.
final class LegacySearchAgent implements GameAgent {
  /// An agent that asks `moves` for the legal moves and what they lead to,
  /// scores positions with `evaluator`, and breaks ties with `random`.
  ///
  /// `nodeBudget` is how many positions it may generate to choose each move.
  ///
  /// Throws a [RangeError] when `nodeBudget` is negative.
  LegacySearchAgent({
    required this._moves,
    required this._evaluator,
    required this._random,
    this._nodeBudget = defaultNodeBudget,
  }) {
    RangeError.checkNotNegative(_nodeBudget, 'nodeBudget');
  }

  /// The node budget of the app's Hard level: deep enough to see a few moves
  /// ahead on a 5 × 5 board, small enough to answer in a fraction of a
  /// second.
  static const int defaultNodeBudget = 20000;

  final MoveGenerator _moves;
  final PositionEvaluator _evaluator;
  final Random _random;
  final int _nodeBudget;

  @override
  Move chooseMove(GameState state) {
    final status = state.status;
    if (status is! InProgress) {
      throw ArgumentError.value(state, 'state', 'The game is over');
    }
    final search = _Search(
      moves: _moves,
      evaluator: _evaluator,
      budget: _nodeBudget,
    );
    return search.bestMove(state, status.toMove, _random);
  }
}

/// A move being considered: the `move`, the `state` it leads to, and its
/// `score` for the player who makes it.
typedef _Candidate = ({Move move, GameState state, int score});

/// The work of choosing one move. It counts the positions it generates. Once
/// the budget is spent, every step returns `null`, which makes the step that
/// called it give up too, all the way back to [bestMove].
final class _Search {
  _Search({
    required this._moves,
    required this._evaluator,
    required this._budget,
  });

  final MoveGenerator _moves;
  final PositionEvaluator _evaluator;

  /// The node budget (see [LegacySearchAgent]).
  final int _budget;

  /// Higher than any real score, as its negative is lower than any. The search
  /// starts from these to mean "no limit yet", because any real score beats
  /// them.
  static const int _infinity = PositionEvaluator.winScore + 1;

  /// The positions generated so far.
  int _generated = 0;

  /// Whether the budget applies yet. The first pass always finishes, so even a
  /// budget of 0 plays as well as looking one move ahead.
  bool _budgetApplies = false;

  /// How many moves ahead the current pass looks.
  int _depth = 1;

  /// Whether the current pass stopped looking at some line of play before that
  /// game ended. When none stopped, it saw every possible ending, so looking
  /// further would change nothing.
  bool _stoppedEarly = false;

  /// The best move for [player] in [state].
  Move bestMove(GameState state, Player player, Random random) {
    final legal = [..._moves.legalMoves(state)]..shuffle(random);
    // Looking 1 move ahead is just playing each move and scoring the result.
    // The budget does not apply yet, so this cannot run out.
    var ranked = _playAll(state, player, legal)!;
    _budgetApplies = true;
    // The line above was the pass that looks 1 move ahead, so the next looks 2.
    for (_depth = 2; ; _depth++) {
      _stoppedEarly = false;
      final deeper = _rescore(ranked, player);
      if (deeper == null) break;
      ranked = deeper;
      if (!_stoppedEarly) break;
    }
    return ranked.first.move;
  }

  /// One pass: the moves in [ranked] scored again for [player], this time
  /// looking [_depth] moves ahead, best first. `null` when the budget runs out
  /// first.
  List<_Candidate>? _rescore(List<_Candidate> ranked, Player player) {
    final opponent = _moves.opponentOf(player);
    var bestSoFar = -_infinity;
    final rescored = <_Candidate>[];
    for (final candidate in ranked) {
      final reply = _lookAhead(
        candidate.state,
        opponent,
        _depth - 1,
        -_infinity,
        -bestSoFar,
      );
      if (reply == null) return null;
      final score = -reply;
      rescored.add((
        move: candidate.move,
        state: candidate.state,
        score: score,
      ));
      bestSoFar = max(bestSoFar, score);
    }
    mergeSort(rescored, compare: _bestFirst);
    return rescored;
  }

  /// The score of [state] for [player], who moves next in it, looking
  /// [movesLeft] more moves ahead. `null` once the budget runs out.
  ///
  /// It tries each move and calls itself to find the opponent's best answer.
  /// One player's gain is the other's loss, so the opponent's score, negated,
  /// is [player]'s. That lets one method play both sides. Textbooks call this
  /// negamax.
  ///
  /// Two limits let it skip moves that cannot matter:
  ///
  /// - [floor] is what [player] can already get by choosing differently
  ///   earlier, so anything lower will not be chosen.
  /// - [ceiling] is the most the opponent will allow. They too can choose
  ///   differently earlier, so once [player] reaches it the opponent avoids
  ///   this position, and the remaining moves here need no look.
  ///
  /// Only a score between the two is exact. Outside them the result just shows
  /// which side it fell on, which is all the caller needs.
  int? _lookAhead(
    GameState state,
    Player player,
    int movesLeft,
    int floor,
    int ceiling,
  ) {
    if (state.status is Finished) {
      return _finalScore(state, player, _depth - movesLeft);
    }
    if (movesLeft == 0) {
      _stoppedEarly = true;
      return _evaluator.score(state, player);
    }
    final candidates = _playAll(state, player, _moves.legalMoves(state));
    if (candidates == null) return null;
    final opponent = _moves.opponentOf(player);
    var best = -_infinity;
    var secured = floor;
    for (final candidate in candidates) {
      // Seen from the opponent's side, scores are negated, so the limits swap.
      final reply = _lookAhead(
        candidate.state,
        opponent,
        movesLeft - 1,
        -ceiling,
        -secured,
      );
      if (reply == null) return null;
      best = max(best, -reply);
      secured = max(secured, best);
      if (secured >= ceiling) break;
    }
    return best;
  }

  /// Plays each of the [legal] moves of [player] from [state] and scores the
  /// result, best first. `null` once the budget runs out.
  List<_Candidate>? _playAll(
    GameState state,
    Player player,
    List<Move> legal,
  ) {
    final candidates = <_Candidate>[];
    for (final move in legal) {
      if (_budgetApplies && _generated >= _budget) return null;
      _generated++;
      final next = _moves.applyLegal(state, move);
      final score = _evaluator.score(next, player);
      candidates.add((move: move, state: next, score: score));
    }
    mergeSort(candidates, compare: _bestFirst);
    return candidates;
  }

  /// The score of the finished game [state] for [player], reached
  /// [movesPlayed] moves from now. A win counts for less the later it comes,
  /// and a loss for less the longer it is put off.
  int _finalScore(GameState state, Player player, int movesPlayed) {
    final score = _evaluator.score(state, player);
    return score > 0 ? score - movesPlayed : score + movesPlayed;
  }

  /// Orders candidates by score, highest first. `mergeSort` keeps the order of
  /// equal items, so equal scores stay in their shuffled order.
  static int _bestFirst(_Candidate a, _Candidate b) =>
      b.score.compareTo(a.score);
}
