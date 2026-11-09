import 'dart:ui' show ErrorCallback, PlatformDispatcher;

import 'package:cephalopod/app/uncaught_error_reporting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('installUncaughtErrorReporting', () {
    late List<(Object, StackTrace, String?)> reports;
    FlutterExceptionHandler? flutterOnError;
    ErrorCallback? platformOnError;

    setUp(() {
      flutterOnError = FlutterError.onError;
      platformOnError = PlatformDispatcher.instance.onError;
      reports = [];
      installUncaughtErrorReporting(
        (error, stackTrace, {reason}) =>
            reports.add((error, stackTrace, reason)),
      );
    });

    // The hooks are global: put back the test framework's own.
    tearDown(() {
      FlutterError.onError = flutterOnError;
      PlatformDispatcher.instance.onError = platformOnError;
    });

    test('reports errors inside Flutter, with what Flutter was doing', () {
      final error = StateError('Broken layout');
      final stackTrace = StackTrace.current;

      FlutterError.onError!(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          context: ErrorDescription('while laying out the board'),
        ),
      );

      expect(reports, [(error, stackTrace, 'while laying out the board')]);
    });

    test('reports every other uncaught error, and keeps the app running', () {
      final error = StateError('Lost after an await');
      final stackTrace = StackTrace.current;

      final handled = PlatformDispatcher.instance.onError!(error, stackTrace);

      expect(reports, [(error, stackTrace, null)]);
      expect(handled, isTrue);
    });
  });
}
