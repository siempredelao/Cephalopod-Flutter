import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/dice_tally_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/dice_tally.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../helpers/phone.dart';
import '../../../../../helpers/real_fonts.dart';

void main() {
  setUpAll(loadRealFonts);

  const playerOne = SideUi(player: PlayerUi.one, role: RoleUi.player);
  const playerTwo = SideUi(player: PlayerUi.two, role: RoleUi.player);
  const tally = DiceTallyUi(
    playerOne: SideTallyUi(side: playerOne, dice: 13, toMove: false),
    playerTwo: SideTallyUi(side: playerTwo, dice: 11, toMove: true),
  );

  Future<void> pumpTally(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) {
    return tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: const Scaffold(
          body: Center(child: DiceTally(tally: tally)),
        ),
      ),
    );
  }

  /// The outline of the chip that says [name].
  BorderSide outlineOf(WidgetTester tester, String name) {
    final chip = find.ancestor(
      of: find.text(name),
      matching: find.byType(DecoratedBox),
    );
    final decoration =
        tester.widget<DecoratedBox>(chip.first).decoration as ShapeDecoration;
    return (decoration.shape as StadiumBorder).side;
  }

  group('DiceTally', () {
    testWidgets("shows each side's name and count, Player 1 first", (
      tester,
    ) async {
      await pumpTally(tester);

      expect(find.text('Player 1'), findsOne);
      expect(find.text('13'), findsOne);
      expect(find.text('Player 2'), findsOne);
      expect(find.text('11'), findsOne);
      expect(
        tester.getCenter(find.text('Player 1')).dx,
        lessThan(tester.getCenter(find.text('Player 2')).dx),
      );
    });

    testWidgets("draws a die in each side's colour", (tester) async {
      await pumpTally(tester);

      final dice = tester.widgetList<DieFace>(find.byType(DieFace)).toList();
      expect([for (final die in dice) die.die.owner], [playerOne, playerTwo]);
    });

    testWidgets('makes the side to move stand out', (tester) async {
      await pumpTally(tester);

      expect(
        outlineOf(tester, 'Player 2').width,
        greaterThan(outlineOf(tester, 'Player 1').width),
      );
    });

    testWidgets('reads the whole count as one sentence', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpTally(tester);

      expect(
        find.bySemanticsLabel('Player 1: 13 dice. Player 2: 11 dice.'),
        findsOne,
      );
      semantics.dispose();
    });

    testWidgets('puts one chip under the other when they do not fit', (
      tester,
    ) async {
      useSmallPhone(tester, const Locale('es'));
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpTally(tester, locale: const Locale('es'));

      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.text('Jugador 2')).dy,
        greaterThan(tester.getCenter(find.text('Jugador 1')).dy),
      );
    });
  });
}
