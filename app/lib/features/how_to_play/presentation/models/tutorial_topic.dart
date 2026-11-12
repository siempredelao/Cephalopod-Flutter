/// What a page of How to play teaches, one value per page, in order.
///
/// A meaning, not text (docs/adr/0018): `TutorialTextMapper` gives each
/// topic its title and its explanation, in the language on screen.
enum TutorialTopic {
  /// The players alternate, placing one die each turn.
  takeTurns,

  /// With nothing to capture, the new die shows 1.
  placeAOne,

  /// Capturing is compulsory when it is possible.
  captureWhenYouCan,

  /// After a capture, the new die shows the captured dice's total.
  dieShowsTheSum,

  /// With more than one possible capture, the player picks which.
  chooseYourCapture,

  /// The game ends on a full board, and the player with more dice wins.
  fillTheBoard,
}
