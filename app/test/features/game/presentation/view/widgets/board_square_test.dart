import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const empty = SquareUi(row: 2, col: 2, die: null, mark: SquareMark.none);
  const withDie = SquareUi(
    row: 2,
    col: 2,
    die: DieUi(
      pips: 3,
      owner: SideUi(player: PlayerUi.one, role: RoleUi.player),
    ),
    mark: SquareMark.none,
  );

  /// Shows [square] in a square of its own. Showing another one after it
  /// updates the same widget, as the board does when the game changes:
  /// with [animateDie] after a move, without it after anything else.
  Future<void> pumpSquare(
    WidgetTester tester,
    SquareUi square, {
    bool animateDie = true,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: Center(
          child: SizedBox.square(
            dimension: 80,
            child: BoardSquare(
              square: square,
              animateDie: animateDie,
              onTap: null,
            ),
          ),
        ),
      ),
    );
  }

  /// How big the die on screen is drawn, from 0 to 1 of its full size.
  double dieScale(WidgetTester tester) {
    final transition = find.ancestor(
      of: find.byType(DieFace),
      matching: find.byType(ScaleTransition),
    );
    return tester.widget<ScaleTransition>(transition).scale.value;
  }

  /// How solid the die on screen is drawn, from 0, unseen, to 1.
  double dieOpacity(WidgetTester tester) {
    final transition = find.descendant(
      of: find.byType(BoardSquare),
      matching: find.byType(FadeTransition),
    );
    return tester.widget<FadeTransition>(transition).opacity.value;
  }

  /// Tells the app that the device asks for less motion.
  void askForLessMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  group('BoardSquare', () {
    testWidgets('grows a die into its square when it appears', (tester) async {
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie);
      expect(dieScale(tester), 0.5);

      await tester.pump(const Duration(milliseconds: 100));
      expect(dieScale(tester), allOf(greaterThan(0.5), lessThan(1)));

      await tester.pumpAndSettle();
      expect(dieScale(tester), 1);
    });

    testWidgets('grows a die that gets a ring as it appears', (tester) async {
      // In a game the new die is also the last move, so its ring appears in
      // the same frame. The ring must not stop the die from growing.
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie.copyWith(mark: SquareMark.lastMove));
      expect(dieScale(tester), 0.5);

      await tester.pumpAndSettle();
      expect(dieScale(tester), 1);
    });

    testWidgets('fades the die in as it grows', (tester) async {
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie);

      expect(dieOpacity(tester), 0);
      await tester.pumpAndSettle();
      expect(dieOpacity(tester), 1);
    });

    testWidgets('keeps the tile under the die while it grows', (tester) async {
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie);
      await tester.pump(const Duration(milliseconds: 50));

      // The first box is the ring's, the second the tile. The tile fills
      // the square but for the ring's room, and the die is drawn over it.
      final square = tester.getSize(find.byType(BoardSquare));
      final boxes = find.descendant(
        of: find.byType(BoardSquare),
        matching: find.byType(DecoratedBox),
      );
      expect(tester.getSize(boxes.at(1)), square - const Offset(12, 12));
      expect(find.byType(DieFace), findsOne);
    });

    testWidgets('draws a die that is there from the start at once', (
      tester,
    ) async {
      await pumpSquare(tester, withDie);

      expect(find.byType(DieFace), findsOne);
      expect(dieScale(tester), 1);
    });

    testWidgets('draws at once a die that appears without a move', (
      tester,
    ) async {
      // A turn taken back brings captured dice back, for one.
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie, animateDie: false);

      expect(dieScale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('draws the die at once when the device asks for less motion', (
      tester,
    ) async {
      askForLessMotion(tester);
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie);

      expect(dieScale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('shrinks a die out of its square when it goes away', (
      tester,
    ) async {
      await pumpSquare(tester, withDie);

      await pumpSquare(tester, empty);
      // The die that was there is still drawn, whole.
      expect(dieScale(tester), 1);
      expect(dieOpacity(tester), 1);

      await tester.pump(const Duration(milliseconds: 100));
      expect(dieScale(tester), allOf(greaterThan(0.5), lessThan(1)));
      expect(dieOpacity(tester), allOf(greaterThan(0), lessThan(1)));

      await tester.pumpAndSettle();
      expect(find.byType(DieFace), findsNothing);
    });

    testWidgets('keeps the tile under the die while it shrinks', (
      tester,
    ) async {
      await pumpSquare(tester, withDie);

      await pumpSquare(tester, empty);
      await tester.pump(const Duration(milliseconds: 100));

      final square = tester.getSize(find.byType(BoardSquare));
      final boxes = find.descendant(
        of: find.byType(BoardSquare),
        matching: find.byType(DecoratedBox),
      );
      expect(tester.getSize(boxes.at(1)), square - const Offset(12, 12));
    });

    testWidgets('takes a die away at once without a move', (tester) async {
      // A turn taken back, or a new game.
      await pumpSquare(tester, withDie);

      await pumpSquare(tester, empty, animateDie: false);

      expect(find.byType(DieFace), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('takes a die away at once when the device asks for less '
        'motion', (tester) async {
      askForLessMotion(tester);
      await pumpSquare(tester, withDie);

      await pumpSquare(tester, empty);

      expect(find.byType(DieFace), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('grows a new die on a square whose die is still shrinking', (
      tester,
    ) async {
      await pumpSquare(tester, withDie);
      await pumpSquare(tester, empty);
      await tester.pump(const Duration(milliseconds: 100));

      const other = DieUi(
        pips: 1,
        owner: SideUi(player: PlayerUi.two, role: RoleUi.player),
      );
      await pumpSquare(tester, withDie.copyWith(die: other));

      expect(tester.widget<DieFace>(find.byType(DieFace)).die, other);
      expect(dieScale(tester), 0.5);
      await tester.pumpAndSettle();
      expect(dieScale(tester), 1);
    });

    testWidgets('brings back at once a die that was shrinking away', (
      tester,
    ) async {
      // A capture taken back before its dice have gone.
      await pumpSquare(tester, withDie);
      await pumpSquare(tester, empty);
      await tester.pump(const Duration(milliseconds: 100));

      await pumpSquare(tester, withDie, animateDie: false);

      expect(dieScale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('changes the die on a square at once', (tester) async {
      await pumpSquare(tester, withDie);

      const other = DieUi(
        pips: 5,
        owner: SideUi(player: PlayerUi.two, role: RoleUi.player),
      );
      await pumpSquare(tester, withDie.copyWith(die: other));

      expect(tester.widget<DieFace>(find.byType(DieFace)).die, other);
      expect(dieScale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
