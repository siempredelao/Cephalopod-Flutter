import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('logError', () {
    late List<String> console;

    setUp(() {
      // Flutter writes only the first error in full, so start from none.
      FlutterError.resetErrorCount();
      console = [];
      final print = debugPrint;
      debugPrint = (message, {wrapWidth}) => console.add(message ?? '');
      addTearDown(() => debugPrint = print);
    });

    test('writes the error and what was happening to the console', () {
      logError(
        StateError('Storage is full'),
        StackTrace.current,
        reason: 'saving the game',
      );

      final output = console.join('\n');
      expect(output, contains('Storage is full'));
      expect(output, contains('saving the game'));
    });

    test('writes an error with no reason', () {
      logError(StateError('Storage is full'), StackTrace.current);

      expect(console.join('\n'), contains('Storage is full'));
    });
  });
}
