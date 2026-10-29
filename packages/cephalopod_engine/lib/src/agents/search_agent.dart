import 'dart:math';

import 'package:cephalopod_engine/src/agents/game_agent.dart';
import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/agents/play_listed_move.dart';
import 'package:cephalopod_engine/src/agents/position_evaluator.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/move.dart';
import 'package:cephalopod_engine/src/models/player.dart';
import 'package:collection/collection.dart';

/// The Hard opponent: looks several moves ahead, assuming the opponent always
/// replies with its best move, and plays the move that leads to the best
/// position it can force, as the [PositionEvaluator] scores it.
///
/// It searches one move deeper at a time (iterative deepening) with
/// alpha-beta pruning, and stops once it has generated `nodeBudget`
/// positions. It then plays the best move of the deepest search it finished.
/// Counting positions instead of time makes its move depend only on the
/// position and the seed, so a slower device thinks longer rather than
/// playing worse (docs/adr/0014).
///
/// Moves are searched best first by their immediate score, which lets
/// alpha-beta skip more of the tree. Equally good moves keep a random order,
/// shuffled with `random`. Of two wins it takes the quicker one.
final class SearchAgent implements GameAgent {
  /// An agent that asks `moves` for the legal moves and what they lead to,
  /// scores positions with `evaluator`, breaks ties with `random`, and
  /// generates at most `nodeBudget` positions per move after the first
  /// depth.
  ///
  /// Throws a [RangeError] when `nodeBudget` is negative.
  SearchAgent({
    required this._moves,
    required this._evaluator,
    required this._random,
    this._nodeBudget = defaultNodeBudget,
  }) {
    RangeError.checkNotNegative(_nodeBudget, 'nodeBudget');
  }

  /// The positions the app's Hard level may generate per move: deep enough
  /// to see a few moves ahead on a 5 × 5 board, small enough to answer in a
  /// fraction of a second.
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

/// A position one move away: the `move`, the `state` it leads to and its
/// `score` for the player who made the move.
typedef _Child = ({Move move, GameState state, int score});

/// One search, for one move. It counts the positions it generates; once the
/// budget is spent, every step returns `null` and the search unwinds.
final class _Search {
  _Search({
    required this._moves,
    required this._evaluator,
    required this._budget,
  });

  final MoveGenerator _moves;
  final PositionEvaluator _evaluator;
  final int _budget;

  /// Larger than any score, so it bounds every search window.
  static const int _infinity = PositionEvaluator.winScore + 1;

  /// The positions generated so far.
  int _generated = 0;

  /// Whether the budget applies yet. The first depth is always finished, so
  /// even a budget of 0 plays as well as looking one move ahead.
  bool _limited = false;

  /// How many moves deep the current iteration searches.
  int _depth = 1;

  /// Whether the current iteration stopped some line before the game ended.
  /// When none did, it saw every ending, and searching deeper changes
  /// nothing.
  bool _cutOff = false;

  /// The best move for [player] in [state].
  Move bestMove(GameState state, Player player, Random random) {
    final legal = [..._moves.legalMoves(state)]..shuffle(random);
    // The budget does not apply yet, so this cannot run out.
    var ranked = _expand(state, player, legal)!;
    _limited = true;
    for (_depth = 2; ; _depth++) {
      _cutOff = false;
      final deeper = _searchRoot(ranked, player);
      if (deeper == null) break;
      ranked = deeper;
      if (!_cutOff) break;
    }
    return ranked.first.move;
  }

  /// [ranked], the moves of [player] at the root, scored [_depth] moves
  /// deep and sorted best first; `null` when the budget runs out first.
  List<_Child>? _searchRoot(List<_Child> ranked, Player player) {
    final opponent = _opponentOf(player);
    var alpha = -_infinity;
    final searched = <_Child>[];
    for (final child in ranked) {
      final reply = _negamax(
        child.state,
        opponent,
        _depth - 1,
        -_infinity,
        -alpha,
      );
      if (reply == null) return null;
      final score = -reply;
      searched.add((move: child.move, state: child.state, score: score));
      alpha = max(alpha, score);
    }
    mergeSort(searched, compare: _bestFirst);
    return searched;
  }

  /// The score of [state] for [player], who moves next in it, looking
  /// [depth] more moves ahead. Only scores between [alpha] and [beta] are
  /// exact; outside them the opponent would avoid this line anyway, so the
  /// search stops early and returns a bound. `null` once the budget runs
  /// out.
  int? _negamax(
    GameState state,
    Player player,
    int depth,
    int alpha,
    int beta,
  ) {
    if (state.status is Finished) {
      return _finalScore(state, player, _depth - depth);
    }
    if (depth == 0) {
      _cutOff = true;
      return _evaluator.score(state, player);
    }
    final children = _expand(state, player, _moves.legalMoves(state));
    if (children == null) return null;
    final opponent = _opponentOf(player);
    var best = -_infinity;
    var low = alpha;
    for (final child in children) {
      final reply = _negamax(child.state, opponent, depth - 1, -beta, -low);
      if (reply == null) return null;
      best = max(best, -reply);
      low = max(low, best);
      if (low >= beta) break;
    }
    return best;
  }

  /// The positions [legal] lead to from [state], best first for [player],
  /// who plays them; `null` once the budget runs out.
  List<_Child>? _expand(GameState state, Player player, List<Move> legal) {
    final children = <_Child>[];
    for (final move in legal) {
      if (_limited && _generated >= _budget) return null;
      _generated++;
      final next = _moves.playListed(state, move);
      final score = _evaluator.score(next, player);
      children.add((move: move, state: next, score: score));
    }
    mergeSort(children, compare: _bestFirst);
    return children;
  }

  /// The score of the finished game [state] for [player], reached [ply]
  /// moves after the root. A win counts for less the later it comes, and a
  /// loss for less the longer it is put off.
  int _finalScore(GameState state, Player player, int ply) {
    final score = _evaluator.score(state, player);
    return score > 0 ? score - ply : score + ply;
  }

  /// Orders children by score, highest first. `mergeSort` is stable, so
  /// equal scores keep their shuffled order.
  static int _bestFirst(_Child a, _Child b) => b.score.compareTo(a.score);

  static Player _opponentOf(Player player) => switch (player) {
    Player.black => Player.white,
    Player.white => Player.black,
  };
}
