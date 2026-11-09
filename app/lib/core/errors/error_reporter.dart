// This file imports nothing, so every layer can take an `ErrorReporter`,
// the domain included, which must stay pure Dart. Keep it that way.

/// Reports an error that nothing else handles: an uncaught one, or one the
/// app chooses to survive, such as a game that could not be saved.
///
/// A plain function, so any layer can take one without knowing where the
/// errors go. `reason` says what was happening, such as "saving the game".
///
/// The composition root picks the reporter: `logError`, which writes to the
/// console, for now, and a crash reporting service once the app is on
/// Google Play (M7).
typedef ErrorReporter = void Function(
  Object error,
  StackTrace stackTrace, {
  String? reason,
});
