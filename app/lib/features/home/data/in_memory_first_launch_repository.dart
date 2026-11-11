import 'package:cephalopod/features/home/domain/first_launch_repository.dart';

/// A [FirstLaunchRepository] that remembers in memory only, so it forgets
/// when the app closes. For tests, and as the reference the contract tests
/// hold other implementations to.
final class InMemoryFirstLaunchRepository implements FirstLaunchRepository {
  /// Starts as a first launch, unless `seenHowToPlay` says How to play was
  /// already shown, as most tests want.
  InMemoryFirstLaunchRepository({this._seenHowToPlay = false});

  bool _seenHowToPlay;

  @override
  Future<bool> hasSeenHowToPlay() async => _seenHowToPlay;

  @override
  Future<void> markHowToPlaySeen() async {
    _seenHowToPlay = true;
  }
}
