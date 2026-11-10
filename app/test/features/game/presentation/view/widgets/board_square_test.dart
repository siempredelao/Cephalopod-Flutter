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
  /// updates the same widget, as the board does when a move is played.
  Future<void> pumpSquare(WidgetTester tester, SquareUi square) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: Center(
          child: SizedBox.square(
            dimension: 80,
            child: BoardSquare(square: square, onTap: null),
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

    testWidgets('fades the die in as it grows', (tester) async {
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie);
      final fade = find.descendant(
        of: find.byType(BoardSquare),
        matching: find.byType(FadeTransition),
      );

      expect(tester.widget<FadeTransition>(fade).opacity.value, 0);
      await tester.pumpAndSettle();
      expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
    });

    testWidgets('keeps the tile under the die while it grows', (tester) async {
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie);
      await tester.pump(const Duration(milliseconds: 50));

      // The tile is the square's whole size, and the die is drawn over it.
      final square = tester.getSize(find.byType(BoardSquare));
      final tile = find.descendant(
        of: find.byType(BoardSquare),
        matching: find.byType(DecoratedBox),
      );
      expect(tester.getSize(tile.first), square - const Offset(12, 12));
      expect(find.byType(DieFace), findsOne);
    });

    testWidgets('draws a die that is there from the start at once', (
      tester,
    ) async {
      await pumpSquare(tester, withDie);

      expect(find.byType(DieFace), findsOne);
      expect(dieScale(tester), 1);
    });

    testWidgets('takes a die away at once', (tester) async {
      await pumpSquare(tester, withDie);
      await tester.pumpAndSettle();

      await pumpSquare(tester, empty);

      expect(find.byType(DieFace), findsNothing);
    });

    testWidgets('draws the die at once when the device asks for less motion', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpSquare(tester, empty);

      await pumpSquare(tester, withDie);

      expect(dieScale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
