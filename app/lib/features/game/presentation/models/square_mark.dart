/// How a square stands out on the board.
enum SquareMark {
  /// Nothing to show.
  none,

  /// The last die was placed here.
  lastMove,

  /// The new die goes here once the player has chosen a capture.
  captureTarget,

  /// A die the player can pick for the capture.
  captureOption,

  /// A die the player has picked for the capture.
  captureSelected,
}
