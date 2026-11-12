/// Remembers whether How to play has been shown on this device. How to play
/// marks it when it opens; the app reads it to open How to play by itself on
/// the first launch only. Every implementation passes the same contract
/// tests.
abstract interface class HowToPlayRepository {
  /// Whether How to play has been shown here before: false until
  /// [markHowToPlaySeen] is called.
  Future<bool> hasSeenHowToPlay();

  /// Remembers that How to play has been shown.
  Future<void> markHowToPlaySeen();
}
