import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpDie(WidgetTester tester, Die die) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: Center(
          child: SizedBox.square(dimension: 60, child: DieFace(die: die)),
        ),
      ),
    );
  }

  CustomPainter painterOf(WidgetTester tester) {
    final paint = find.descendant(
      of: find.byType(DieFace),
      matching: find.byType(CustomPaint),
    );
    return tester.widget<CustomPaint>(paint).painter!;
  }

  group('DieFace', () {
    for (final owner in Player.values) {
      for (var pips = 1; pips <= 6; pips++) {
        testWidgets('draws a ${owner.name} die showing $pips', (tester) async {
          await pumpDie(tester, Die(owner: owner, pips: pips));

          expect(tester.takeException(), isNull);
          expect(find.byType(DieFace), findsOneWidget);
        });
      }
    }

    testWidgets('repaints only when the die changes', (tester) async {
      await pumpDie(tester, const Die(owner: Player.black, pips: 3));
      final three = painterOf(tester);
      await pumpDie(tester, const Die(owner: Player.black, pips: 3));
      final sameThree = painterOf(tester);
      await pumpDie(tester, const Die(owner: Player.white, pips: 3));
      final whiteThree = painterOf(tester);
      await pumpDie(tester, const Die(owner: Player.white, pips: 4));
      final whiteFour = painterOf(tester);

      expect(sameThree.shouldRepaint(three), isFalse);
      expect(whiteThree.shouldRepaint(sameThree), isTrue);
      expect(whiteFour.shouldRepaint(whiteThree), isTrue);
    });
  });
}
