/// How long a die takes to grow into its square, or to shrink out of it.
///
/// Long enough to see what changed.
const Duration dieAnimationDuration = Duration(milliseconds: 500);

/// How long the game waits after a move before the next one starts: taps
/// are ignored, and the computer does not reply, until then.
///
/// As long as the die animation, so the board has stopped moving by then.
const Duration moveSettleDuration = dieAnimationDuration;
