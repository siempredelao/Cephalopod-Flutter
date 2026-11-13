import 'package:cephalopod/core/l10n/locale_resolution.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const english = Locale('en');
  const spanish = Locale('es');
  const bokmal = Locale('nb');

  /// The languages the app will speak with Norwegian, English first.
  const supported = [english, spanish, bokmal];

  group('resolveAppLocale', () {
    test('gives a phone its language when the app speaks it', () {
      expect(resolveAppLocale([spanish], supported), spanish);
      expect(resolveAppLocale([const Locale('es', 'MX')], supported), spanish);
    });

    test('gives English to a phone in a language the app does not speak', () {
      expect(resolveAppLocale([const Locale('fr')], supported), english);
      expect(resolveAppLocale(const [], supported), english);
      expect(resolveAppLocale(null, supported), english);
    });

    test('gives Bokmål to a phone that says Norwegian as no or nn', () {
      for (final code in ['no', 'nn', 'nb']) {
        expect(resolveAppLocale([Locale(code)], supported), bokmal);
        expect(resolveAppLocale([Locale(code, 'NO')], supported), bokmal);
      }
    });

    test('keeps the order of the languages a phone prefers', () {
      expect(
        resolveAppLocale([const Locale('nn'), spanish], supported),
        bokmal,
      );
      expect(
        resolveAppLocale([spanish, const Locale('nn')], supported),
        spanish,
      );
    });

    test('gives English to a Norwegian phone while the app lacks Bokmål', () {
      const withoutNorwegian = [english, spanish];

      expect(resolveAppLocale([const Locale('no')], withoutNorwegian), english);
    });
  });
}
