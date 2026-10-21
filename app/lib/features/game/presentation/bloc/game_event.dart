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

/// Start a new game under [config], dropping the current one.
final class GameStarted extends GameEvent {
  const GameStarted([this.config = GameConfig.standard]);

  final GameConfig config;
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
