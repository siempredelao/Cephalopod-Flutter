import 'dart:convert';
import 'dart:io';

import 'package:cephalopod/core/navigation/app_route.dart';
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

/// What every message key starts with: the name of the screen it belongs
/// to, as its route is named, or `app` for words shared across screens.
/// A new screen gets its prefix with its route.
final Set<String> _prefixes = {
  'app',
  for (final route in AppRoute.values) route.name,
};

/// Whether [key] starts with one of the [_prefixes], followed by the next
/// word: `gameSquareEmpty` does, `gamesWon` and `squareEmpty` do not.
bool _isPrefixed(String key) {
  return _prefixes.any(
    (prefix) =>
        key.length > prefix.length &&
        key.startsWith(prefix) &&
        key[prefix.length].toUpperCase() == key[prefix.length],
  );
}

void main() {
  group('The .arb files', () {
    final translations = [
      for (final file in Directory(_arbFolder).listSync())
        if (file.path.endsWith('.arb') && !file.path.endsWith(_template))
          file.path,
    ];

    test("start each message with its screen's name", () {
      final english = _keysOf('$_arbFolder/$_template');

      expect(
        english.where((key) => !_isPrefixed(key)),
        isEmpty,
        reason: 'Start each key with one of $_prefixes',
      );
    });

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
