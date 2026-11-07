import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  /// A die of [player]'s showing [pips].
  DieUi dieOf(PlayerUi player, int pips) {
    final owner = SideUi(player: player, role: RoleUi.player);
    return DieUi(pips: pips, owner: owner);
  }

  Future<void> pumpDie(WidgetTester tester, DieUi die) {
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
    for (final player in PlayerUi.values) {
      for (var pips = 1; pips <= 6; pips++) {
        testWidgets('draws a die of player ${player.name} showing $pips', (
          tester,
        ) async {
          await pumpDie(tester, dieOf(player, pips));

          expect(tester.takeException(), isNull);
          expect(find.byType(DieFace), findsOneWidget);
        });
      }
    }

    testWidgets('repaints only when the die changes', (tester) async {
      await pumpDie(tester, dieOf(PlayerUi.one, 3));
      final three = painterOf(tester);
      await pumpDie(tester, dieOf(PlayerUi.one, 3));
      final sameThree = painterOf(tester);
      await pumpDie(tester, dieOf(PlayerUi.two, 3));
      final otherThree = painterOf(tester);
      await pumpDie(tester, dieOf(PlayerUi.two, 4));
      final otherFour = painterOf(tester);

      expect(sameThree.shouldRepaint(three), isFalse);
      expect(otherThree.shouldRepaint(sameThree), isTrue);
      expect(otherFour.shouldRepaint(otherThree), isTrue);
    });
  });
}
