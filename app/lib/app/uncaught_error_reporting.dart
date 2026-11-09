import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:flutter/foundation.dart';

/// Sends every error that nothing else catches to [report]. Between them,
/// Flutter's two hooks see all of them:
///
/// - `FlutterError.onError`: errors inside Flutter, such as while building
///   or laying out a widget.
/// - `PlatformDispatcher.onError`: every other uncaught error, such as one
///   thrown after an `await`.
///
/// Errors inside a bloc's event handler arrive through the second hook:
/// bloc reports them to its `BlocObserver`, then throws them again. A
/// `BlocObserver` that reported too would report each of them twice.
void installUncaughtErrorReporting(ErrorReporter report) {
  FlutterError.onError = (details) => report(
    details.exception,
    details.stack ?? StackTrace.empty,
    reason: details.context?.toDescription(),
  );
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    report(error, stackTrace);
    // Handled: the app keeps running.
    return true;
  };
}
