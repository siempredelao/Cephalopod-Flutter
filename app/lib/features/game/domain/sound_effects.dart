/// Plays the game's sounds.
///
/// Playing a sound never fails for the caller: a sound that cannot play is
/// simply not heard. Each call starts the sound and returns once it has
/// started, so callers need not wait for it.
abstract interface class SoundEffects {
  /// A short pop, for dice that are captured.
  Future<void> playCapture();

  /// A rising chime, for a win.
  Future<void> playWin();
}
