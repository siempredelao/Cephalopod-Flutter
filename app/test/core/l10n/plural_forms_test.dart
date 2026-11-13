import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The languages whose counts are not English's "one, or else many".
void main() {
  group('Polish', () {
    final polish = lookupAppLocalizations(const Locale('pl'));

    test('says "kość" for one die and "kości" for any other count', () {
      expect(polish.gameTallySide('Ty', 1), 'Ty: 1 kość');
      for (final count in [0, 2, 4, 5, 12, 21, 22, 25]) {
        expect(polish.gameTallySide('Ty', count), 'Ty: $count kości');
      }
    });

    test('counts the dice a hint would capture with the same forms', () {
      String hint(int captures) =>
          polish.gameHeadlineWithHint(2, 3, captures, 'Twój ruch');

      expect(
        hint(0),
        'Podpowiedź: umieść kość w wierszu 2, kolumnie 3. '
        'Twój ruch',
      );
      expect(hint(1), contains('i zbij 1 kość.'));
      expect(hint(3), contains('i zbij 3 kości.'));
      expect(hint(5), contains('i zbij 5 kości.'));
    });
  });

  group('Turkish', () {
    final turkish = lookupAppLocalizations(const Locale('tr'));

    test('keeps the noun singular after a number', () {
      expect(turkish.gameTallySide('Sen', 1), 'Sen: 1 zar');
      expect(turkish.gameTallySide('Sen', 5), 'Sen: 5 zar');
    });
  });
}
