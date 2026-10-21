import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Something the player did on the game screen.
///
/// Events report what happened, not what it means: a tapped square places a
/// die or picks a die to capture depending on the phase, and `GameBloc`
/// decides which. Plain sealed classes, because nothing compares or copies
/// events (docs/adr/0011).
sealed class GameEvent {
  const GameEvent();
}

/// Start a new game under [config], replacing the current one and the
/// saved game.
final class GameStarted extends GameEvent {
  const GameStarted([this.config = GameConfig.standard]);

  final GameConfig config;
}

/// Pick up the saved game, or start a new one when there is none.
final class GameResumed extends GameEvent {
  const GameResumed();
}

/// The player tapped the square at [position].
final class SquareTapped extends GameEvent {
  const SquareTapped(this.position);

  final Position position;
}

/// The player confirmed the dice picked for a capture.
final class CaptureConfirmed extends GameEvent {
  const CaptureConfirmed();
}

/// The player backed out of choosing a capture.
final class CaptureCancelled extends GameEvent {
  const CaptureCancelled();
}

/// The player took back the last move.
final class UndoRequested extends GameEvent {
  const UndoRequested();
}

/// The player played again the last move they took back.
final class RedoRequested extends GameEvent {
  const RedoRequested();
}
