import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:flutter/foundation.dart';

/// An [ErrorReporter] that writes [error] to the console the way Flutter
/// writes its own errors: in full, with the stack, in debug builds, and as
/// one line in release builds.
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
