import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:cephalopod/features/rules/presentation/view/rules_page.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Flavor flavor = Flavor.prod,
    String location = '/',
  }) async {
    await tester.pumpWidget(
      App(
        flavor: flavor,
        router: createRouter(
          rules: CephalopodRules(),
          initialLocation: location,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('App', () {
    testWidgets('starts on the home page', (tester) async {
      await pumpApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('opens a new game from home', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'New game'));
      await tester.pumpAndSettle();

      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets('goes back home from a deep link to a game', (tester) async {
      await pumpApp(tester, location: '/game');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(GamePage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('opens how to play from home', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'How to play'));
      await tester.pumpAndSettle();

      expect(find.byType(RulesPage), findsOneWidget);
    });

    testWidgets('opens the rules from a game and returns to it', (
      tester,
    ) async {
      await pumpApp(tester, location: '/game');
      await tester.tap(find.byType(BoardSquare).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('How to play'));
      await tester.pumpAndSettle();
      expect(find.byType(RulesPage), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(RulesPage), findsNothing);
      expect(find.byType(DieFace), findsOneWidget);
    });

    testWidgets('opens the about page from home', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'About'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutPage), findsOneWidget);
    });

    testWidgets('goes back home from a deep link to about', (tester) async {
      await pumpApp(tester, location: '/about');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(AboutPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('credits Mark Steere on the about page', (tester) async {
      await pumpApp(tester, location: '/about');

      expect(find.textContaining('Mark Steere'), findsOneWidget);
    });

    testWidgets('shows the debug banner in the dev flavor', (tester) async {
      await pumpApp(tester, flavor: Flavor.dev);

      expect(find.byType(CheckedModeBanner), findsOneWidget);
    });

    testWidgets('hides the debug banner in the prod flavor', (tester) async {
      await pumpApp(tester);

      expect(find.byType(CheckedModeBanner), findsNothing);
    });
  });
}
