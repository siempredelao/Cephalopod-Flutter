import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_ring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const colors = BoardColors.light;
  const tileKey = Key('tile');

  Future<void> pumpRing(WidgetTester tester, SquareMark mark) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [colors]),
        home: Center(
          child: SizedBox.square(
            dimension: 60,
            child: SquareRing(
              mark: mark,
              child: const SizedBox.expand(key: tileKey),
            ),
          ),
        ),
      ),
    );
  }

  /// The ring's decoration.
  BoxDecoration ringOf(WidgetTester tester) {
    final ring = find.descendant(
      of: find.byType(SquareRing),
      matching: find.byType(DecoratedBox),
    );
    return tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
  }

  group('SquareRing', () {
    testWidgets('draws no ring without a mark', (tester) async {
      await pumpRing(tester, SquareMark.none);

      expect(ringOf(tester).border, isNull);
    });

    final colorOf = {
      SquareMark.lastMove: colors.lastMove,
      SquareMark.captureTarget: colors.captureTarget,
      SquareMark.captureOption: colors.captureOption,
      SquareMark.captureSelected: colors.captureSelected,
    };
    for (final MapEntry(key: mark, value: color) in colorOf.entries) {
      testWidgets('rings ${mark.name} in its colour', (tester) async {
        await pumpRing(tester, mark);

        final border = ringOf(tester).border! as Border;
        expect(border.top.color, color);
      });
    }

    testWidgets('keeps the tile the same size with or without a ring', (
      tester,
    ) async {
      await pumpRing(tester, SquareMark.none);
      final plain = tester.getSize(find.byKey(tileKey));

      await pumpRing(tester, SquareMark.lastMove);

      expect(tester.getSize(find.byKey(tileKey)), plain);
      expect(plain, const Size(48, 48));
    });
  });
}
