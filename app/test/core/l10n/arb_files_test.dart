import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Where the translations live, from the app's folder, where tests run.
const String _arbFolder = 'lib/core/l10n';

/// The English file, which every other language follows.
const String _template = 'app_en.arb';

/// The message keys in the .arb file at [path], without the descriptions
/// (`@key`) and the file's own settings (`@@locale`).
Set<String> _keysOf(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  return {
    for (final key in json.keys)
      if (!key.startsWith('@')) key,
  };
}

void main() {
  group('The .arb files', () {
    final translations = [
      for (final file in Directory(_arbFolder).listSync())
        if (file.path.endsWith('.arb') && !file.path.endsWith(_template))
          file.path,
    ];

    test('include a language besides English', () {
      expect(translations, isNotEmpty);
    });

    // gen-l10n falls back to English for a missing message without failing,
    // so a forgotten line would show up in English on a Spanish phone.
    test('have the same messages in every language', () {
      final english = _keysOf('$_arbFolder/$_template');

      for (final translation in translations) {
        final keys = _keysOf(translation);
        expect(
          english.difference(keys),
          isEmpty,
          reason: '$translation is missing these messages',
        );
        expect(
          keys.difference(english),
          isEmpty,
          reason: '$translation has messages that English does not',
        );
      }
    });
  });
}
