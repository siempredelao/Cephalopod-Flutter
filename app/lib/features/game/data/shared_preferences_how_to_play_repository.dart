import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/game/domain/how_to_play_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [HowToPlayRepository] on shared_preferences (docs/adr/0012), with one
/// key for How to play.
///
/// Storage never stops the app (docs/adr/0016). When shared_preferences
/// fails, the error goes to the [ErrorReporter] and the app goes on. A
/// failed read counts as seen: a broken store must not open the tutorial
/// on every launch. A failed write leaves How to play to show again next
/// time.
///
/// Only `Exception`s are caught, which is how storage reports a failure. An
/// `Error` is a bug, so it goes on to the app-wide error reporting.
final class SharedPreferencesHowToPlayRepository
    implements HowToPlayRepository {
  SharedPreferencesHowToPlayRepository({
    required this._sharedPreferencesAsync,
    required this._errorReporter,
  });

  final SharedPreferencesAsync _sharedPreferencesAsync;
  final ErrorReporter _errorReporter;

  static const String _howToPlaySeenKey = 'howToPlaySeen';

  @override
  Future<bool> hasSeenHowToPlay() async {
    try {
      return await _sharedPreferencesAsync.getBool(_howToPlaySeenKey) ?? false;
    } on Exception catch (error, stackTrace) {
      _errorReporter(
        error,
        stackTrace,
        reason: 'reading whether How to play was seen',
      );
      return true;
    }
  }

  @override
  Future<void> markHowToPlaySeen() async {
    try {
      await _sharedPreferencesAsync.setBool(_howToPlaySeenKey, true);
    } on Exception catch (error, stackTrace) {
      _errorReporter(
        error,
        stackTrace,
        reason: 'saving that How to play was seen',
      );
    }
  }
}
