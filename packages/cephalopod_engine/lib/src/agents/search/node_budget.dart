/// The node budget of one search: how many positions it may generate to
/// choose one move.
///
/// A node is one position the search generates by playing a move, real or
/// imagined. Counting positions instead of seconds makes the chosen move
/// depend only on the position and the seed, so a slower device thinks
/// longer rather than playing worse (docs/adr/0014).
///
/// The first pass, looking 1 move ahead, is free: its positions are counted
/// but never refused, so even a budget of 0 plays as well as looking one move
/// ahead. Call [enforce] once it has finished.
final class NodeBudget {
  /// A budget of `limit` positions, not enforced yet.
  ///
  /// Throws a [RangeError] when `limit` is negative.
  NodeBudget(this._limit) {
    RangeError.checkNotNegative(_limit, 'limit');
  }

  /// How many positions the search may generate in total, first pass
  /// included, once the budget is enforced.
  final int _limit;

  int _spent = 0;
  bool _enforced = false;
  bool _ranOut = false;

  /// The positions generated so far, including those of the free first pass.
  int get spent => _spent;

  /// Whether a position has been refused. Once true it stays true: the pass
  /// that was running cannot finish, so its result must be thrown away.
  bool get ranOut => _ranOut;

  /// Turns the limit on.
  ///
  /// Until this is called, [trySpend] allows every position, so the first
  /// pass always finishes. From then on, it refuses each position once the
  /// total generated, counting the first pass, has reached the limit.
  void enforce() {
    _enforced = true;
  }

  /// Counts one more position and returns `true`, or returns `false` and
  /// marks the budget as [ranOut] when it is enforced and already spent.
  bool trySpend() {
    if (_enforced && _spent >= _limit) {
      _ranOut = true;
      return false;
    }

    _spent++;
    return true;
  }
}
