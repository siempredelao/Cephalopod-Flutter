import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Where the app's code is, from the app's folder, where tests run.
const String _codeFolder = 'lib';

/// A change of letter case, which Dart does the same way in every language.
final RegExp _caseConversion = RegExp(r'\.to(Upper|Lower)Case\(');

/// The Dart files of the app, without the generated ones.
Iterable<File> _appFiles() {
  return Directory(_codeFolder)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.contains('generated'));
}

void main() {
  // In Turkish, the capital of "i" is "İ" and the small form of "I" is "ı",
  // but Dart's toUpperCase() and toLowerCase() give "I" and "i" in every
  // language. A word in capitals is written that way in the .arb file, or
  // drawn with a style that knows the language.
  test('the app does not change the case of words itself', () {
    final changing = [
      for (final file in _appFiles())
        if (_caseConversion.hasMatch(file.readAsStringSync())) file.path,
    ];

    expect(changing, isEmpty);
  });
}
