import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_ring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const colors = BoardColors.light;
  const tileKey = Key('tile');

  Future<void> pumpRing(
    WidgetTester tester,
    SquareMark mark, {
    BoardColors palette = colors,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [palette]),
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

  /// How far the ring's glow spreads now.
  double glowOf(WidgetTester tester) =>
      ringOf(tester).boxShadow!.single.blurRadius;

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
      SquareMark.hintTarget: colors.hintTarget,
      SquareMark.hintCapture: colors.hintCapture,
    };
    for (final MapEntry(key: mark, value: color) in colorOf.entries) {
      testWidgets('rings ${mark.name} in its colour', (tester) async {
        await pumpRing(tester, mark);

        final border = ringOf(tester).border! as Border;
        expect(border.top.color, color);
      });
    }

    group("on a hint's square", () {
      testWidgets('pulses as it appears, then holds still', (tester) async {
        await pumpRing(tester, SquareMark.lastMove);
        final still = glowOf(tester);

        await pumpRing(tester, SquareMark.hintTarget);
        // A sixth of the way through: the top of the first pulse.
        await tester.pump(SquareRing.pulseDuration ~/ 6);
        expect(glowOf(tester), greaterThan(still));

        await tester.pumpAndSettle();
        expect(glowOf(tester), still);
        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('pulses once, not again when the theme changes', (
        tester,
      ) async {
        await pumpRing(tester, SquareMark.hintTarget);
        await tester.pumpAndSettle();
        final still = glowOf(tester);

        await pumpRing(
          tester,
          SquareMark.hintTarget,
          palette: BoardColors.dark,
        );
        // Where the first pulse would be at its top. The theme itself
        // fades from one palette to the other meanwhile.
        await tester.pump(SquareRing.pulseDuration ~/ 6);

        expect(glowOf(tester), still);
      });

      testWidgets('pulses again for a new hint', (tester) async {
        await pumpRing(tester, SquareMark.hintTarget);
        await tester.pumpAndSettle();

        await pumpRing(tester, SquareMark.none);
        await pumpRing(tester, SquareMark.hintTarget);

        expect(tester.hasRunningAnimations, isTrue);
        await tester.pumpAndSettle();
      });

      testWidgets('does not pulse when the device asks for less motion', (
        tester,
      ) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );

        await pumpRing(tester, SquareMark.hintTarget);

        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('does not pulse around the dice it would capture', (
        tester,
      ) async {
        await pumpRing(tester, SquareMark.hintCapture);

        expect(tester.hasRunningAnimations, isFalse);
      });
    });

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
