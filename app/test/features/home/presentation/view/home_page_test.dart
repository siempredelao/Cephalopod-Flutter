import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:cephalopod/features/home/presentation/view/home_view.dart';
import 'package:cephalopod/features/home/presentation/view/widgets/demo_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  group('HomePage', () {
    Future<void> pumpHome(
      WidgetTester tester, {
      required bool hasGameToContinue,
    }) async {
      await tester.pumpWidget(
        localizedApp(
          // The demo board reads the board's colours from the theme.
          Theme(
            data: ThemeData(extensions: const [BoardColors.light]),
            child: HomePage(
              createCubit: () => HomeCubit(
                hasGameToContinue: () async => hasGameToContinue,
                hasSeenHowToPlay: () async => true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('offers only a new game when nothing is saved', (tester) async {
      await pumpHome(tester, hasGameToContinue: false);

      expect(find.text('Continue'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'New game'), findsOne);
    });

    testWidgets('offers to continue when a game is saved', (tester) async {
      await pumpHome(tester, hasGameToContinue: true);

      expect(find.widgetWithText(FilledButton, 'Continue'), findsOne);
      expect(find.text('New game'), findsOne);
    });

    testWidgets('says what the game is in one short line', (tester) async {
      await pumpHome(tester, hasGameToContinue: false);

      expect(find.text('Place dice. Add them up. Capture.'), findsOne);
    });

    testWidgets('plays a demo board above the title', (tester) async {
      await pumpHome(tester, hasGameToContinue: false);

      final demo = tester.getRect(find.byType(DemoBoard));
      final title = tester.getRect(find.text('Cephalopod'));

      expect(demo.bottom, lessThanOrEqualTo(title.top));
      expect(demo.center.dx, moreOrLessEquals(title.center.dx, epsilon: 0.5));
    });

    testWidgets('gives the main button the width of the screen', (
      tester,
    ) async {
      await pumpHome(tester, hasGameToContinue: false);

      final screen = tester.getSize(find.byType(HomeView));
      final button = tester.getSize(
        find.widgetWithText(FilledButton, 'New game'),
      );

      // 24 px of space on each side of the page.
      expect(button.width, screen.width - 2 * 24);
    });

    testWidgets('puts How to play, Settings and About in a row below it', (
      tester,
    ) async {
      await pumpHome(tester, hasGameToContinue: false);

      final main = tester.getRect(
        find.widgetWithText(FilledButton, 'New game'),
      );
      final links = [
        for (final label in ['How to play', 'Settings', 'About'])
          tester.getRect(find.widgetWithText(TextButton, label)),
      ];

      for (final link in links) {
        expect(link.top, greaterThanOrEqualTo(main.bottom));
        expect(link.top, links.first.top);
      }
      expect(links[0].right, lessThanOrEqualTo(links[1].left));
      expect(links[1].right, lessThanOrEqualTo(links[2].left));
    });

    testWidgets('names every button for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpHome(tester, hasGameToContinue: true);

      for (final label in [
        'Continue',
        'New game',
        'How to play',
        'Settings',
        'About',
      ]) {
        expect(find.bySemanticsLabel(label), findsOne, reason: label);
      }
      semantics.dispose();
    });

    testWidgets("fades the theme's teal into the background", (tester) async {
      await pumpHome(tester, hasGameToContinue: false);

      final scheme = Theme.of(tester.element(find.byType(HomeView)))
          .colorScheme;
      final background = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((decoration) => decoration.gradient)
          .whereType<LinearGradient>()
          .single;

      expect(background.colors, [scheme.primaryContainer, scheme.surface]);
    });
  });
}
