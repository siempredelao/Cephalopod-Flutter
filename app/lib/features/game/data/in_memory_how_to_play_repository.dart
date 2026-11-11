import 'package:cephalopod/features/game/domain/how_to_play_repository.dart';

/// A [HowToPlayRepository] that remembers in memory only, so it forgets
/// when the app closes. For tests, and as the reference the contract tests
/// hold other implementations to.
final class InMemoryHowToPlayRepository implements HowToPlayRepository {
  /// Starts with How to play never shown, unless `seenHowToPlay` says it
  /// was, as most tests want.
  InMemoryHowToPlayRepository({this._seenHowToPlay = false});

  bool _seenHowToPlay;

  @override
  Future<bool> hasSeenHowToPlay() async => _seenHowToPlay;

  @override
  Future<void> markHowToPlaySeen() async {
    _seenHowToPlay = true;
  }
}
