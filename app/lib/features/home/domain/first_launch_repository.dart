/// Remembers what the player has already been shown on this device, so Home
/// can greet a first launch differently from the ones after. Every
/// implementation passes the same contract tests.
abstract interface class FirstLaunchRepository {
  /// Whether How to play has been shown here before: false until
  /// [markHowToPlaySeen] is called.
  Future<bool> hasSeenHowToPlay();

  /// Remembers that How to play has been shown.
  Future<void> markHowToPlaySeen();
}
