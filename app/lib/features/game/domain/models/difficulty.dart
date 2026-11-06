/// How strongly the computer plays. Each level is one of the engine's agents
/// (docs/adr/0014).
enum Difficulty {
  /// Any legal move, at random.
  easy,

  /// The move that leaves the best position, looking one move ahead.
  medium,

  /// The best move found by searching a few moves ahead.
  hard,
}
