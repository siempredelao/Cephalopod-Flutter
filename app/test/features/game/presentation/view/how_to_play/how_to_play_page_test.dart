import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/how_to_play_page.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/tutorial_steps.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpTutorial(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [BoardColors.light]),
        home: const HowToPlayPage(),
      ),
    );
  }

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
  }

  group('HowToPlayPage', () {
    testWidgets('starts on the first step, with its board', (tester) async {
      await pumpTutorial(tester);

      expect(find.text(tutorialSteps.first.title), findsOne);
      expect(find.byType(GameBoard), findsOne);
    });

    testWidgets('turns the page on Next', (tester) async {
      await pumpTutorial(tester);

      await tapNext(tester);

      expect(find.text(tutorialSteps[1].title), findsOne);
      expect(find.text(tutorialSteps.first.title), findsNothing);
    });

    testWidgets('keeps the board in the same place on every page', (
      tester,
    ) async {
      await pumpTutorial(tester);
      final first = tester.getRect(find.byType(GameBoard));

      for (var step = 1; step < tutorialSteps.length; step++) {
        await tapNext(tester);
        expect(tester.getRect(find.byType(GameBoard)), first);
      }
    });

    testWidgets('turns the page on a swipe', (tester) async {
      await pumpTutorial(tester);

      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text(tutorialSteps[1].title), findsOne);
    });

    testWidgets('says which step is showing', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpTutorial(tester);

      final count = tutorialSteps.length;
      expect(find.bySemanticsLabel('Step 1 of $count'), findsOne);
      await tapNext(tester);
      expect(find.bySemanticsLabel('Step 2 of $count'), findsOne);
      semantics.dispose();
    });

    testWidgets('closes with Got it on the last step', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [BoardColors.light]),
          routes: {
            '/': (_) => const Text('Home'),
            '/how-to-play': (_) => const HowToPlayPage(),
          },
          initialRoute: '/how-to-play',
        ),
      );

      for (var step = 1; step < tutorialSteps.length; step++) {
        await tapNext(tester);
      }
      expect(find.text(tutorialSteps.last.title), findsOne);
      await tester.tap(find.widgetWithText(FilledButton, 'Got it'));
      await tester.pumpAndSettle();

      expect(find.byType(HowToPlayPage), findsNothing);
      expect(find.text('Home'), findsOne);
    });
  });
}
