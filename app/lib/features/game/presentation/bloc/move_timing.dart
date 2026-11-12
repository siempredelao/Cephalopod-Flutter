import 'package:cephalopod/core/board/board_durations.dart';

/// How much later each captured die starts than the one before it, in
/// reading order, so the dice go one at a time rather than all at once.
const Duration captureStagger = Duration(milliseconds: 150);

/// How long the game waits after a move that captured [captures] dice before
/// the next one starts: taps are ignored, and the computer does not reply,
/// until then.
///
/// The die animation, so the board has stopped moving by then, plus one
/// [captureStagger] for each captured die after the first, so the last die
/// has finished too. With no capture, just the die animation.
Duration settleDurationFor(int captures) {
  final staggered = captures > 1 ? captures - 1 : 0;
  return dieAnimationDuration + captureStagger * staggered;
}
