import 'package:cephalopod/core/board/board_durations.dart';

/// How long the game waits after a move before the next one starts: taps
/// are ignored, and the computer does not reply, until then.
///
/// As long as the die animation, so the board has stopped moving by then.
const Duration moveSettleDuration = dieAnimationDuration;
