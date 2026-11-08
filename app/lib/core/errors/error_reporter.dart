import 'package:flutter/foundation.dart';

/// Reports an error that nothing else handles: an uncaught one, or one the
/// app chooses to survive, such as a game that could not be saved.
///
/// A plain function, so any layer can take one without knowing where the
/// errors go. [reason] says what was happening, such as "saving the game".
///
/// The composition root picks the reporter: [logError] for now, and a crash
/// reporting service once the app is on Google Play (M7).
typedef ErrorReporter = void Function(
  Object error,
  StackTrace stackTrace, {
  String? reason,
});

/// Writes [error] to the console the way Flutter writes its own errors: in
/// full, with the stack, in debug builds, and as one line in release builds.
void logError(Object error, StackTrace stackTrace, {String? reason}) {
  FlutterError.dumpErrorToConsole(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'cephalopod',
      context: reason == null ? null : ErrorDescription(reason),
    ),
  );
}
