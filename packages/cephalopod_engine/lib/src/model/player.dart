/// One of the two sides in a game of Cephalopod.
///
/// Each player owns the dice of one colour. Players alternate turns,
/// placing exactly one die per turn (rules R1 and R2).
enum Player {
  /// The player with the black dice.
  black,

  /// The player with the white dice.
  white;

  /// The player who moves after this one.
  Player get opponent => switch (this) {
    Player.black => Player.white,
    Player.white => Player.black,
  };
}
