/// The screen's numbering of the two players. The engine follows the rule
/// sheet's black and white, but the board shows coral and cream dice, so the
/// screen numbers them instead: Player 1 plays black, which moves first under
/// the standard rules.
enum PlayerUi {
  /// Player 1, black in the engine.
  one,

  /// Player 2, white in the engine.
  two,
}
