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

/// The messages in the .arb file at [path], by key: the text with its
/// placeholders, not the descriptions.
Map<String, String> _messagesOf(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@')) key: value! as String,
  };
}

/// Every placeholder in a message, plural counts included: `{name}` and
/// `{name, plural, ...}`.
final RegExp _placeholder = RegExp(r'\{(\w+)[,}]');

/// The placeholder a plural in a message counts with: `count` in
/// `{count, plural, one{...} other{...}}`.
final RegExp _pluralCount = RegExp(r'\{(\w+),\s*plural,');

Set<String> _placeholdersOf(String message) {
  return {for (final match in _placeholder.allMatches(message)) match[1]!};
}

Set<String> _pluralCountsOf(String message) {
  return {for (final match in _pluralCount.allMatches(message)) match[1]!};
}

/// Calls [check] for each message of [translations], with where it is
/// (its key and file), its English text and its text in that language. A
/// message the language lacks is an empty text.
void _eachTranslation(
  List<String> translations,
  void Function(String where, String english, String translated) check,
) {
  final english = _messagesOf('$_arbFolder/$_template');
  for (final path in translations) {
    final messages = _messagesOf(path);
    for (final MapEntry(:key, value: englishText) in english.entries) {
      check('$key in $path', englishText, messages[key] ?? '');
    }
  }
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

    test('use the same placeholders as English in every message', () {
      _eachTranslation(translations, (where, english, translated) {
        expect(
          _placeholdersOf(translated),
          _placeholdersOf(english),
          reason: where,
        );
      });
    });

    // Languages count differently (Polish has `few` and `many`), so a message
    // that counts in English must count with a plural in every language. A
    // language may use one where English has none: Spanish says "con 3
    // puntos" where English says "showing 3".
    test('count with a plural wherever English does', () {
      _eachTranslation(translations, (where, english, translated) {
        expect(
          _pluralCountsOf(translated),
          containsAll(_pluralCountsOf(english)),
          reason: where,
        );
      });
    });
  });
}
