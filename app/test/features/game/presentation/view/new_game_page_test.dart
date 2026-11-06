import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/presentation/view/new_game_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('NewGamePage', () {
    /// The new-game screen, with a game route that shows the query it was
    /// opened with.
    Future<void> pumpNewGame(WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const NewGamePage(),
            routes: [
              GoRoute(
                path: 'game',
                name: AppRoute.game.name,
                builder: (_, state) => Text('Game ?${state.uri.query}'),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    testWidgets('offers a friend, with nothing more to choose', (tester) async {
      await pumpNewGame(tester);

      expect(find.text('A friend'), findsOne);
      expect(find.text('Difficulty'), findsNothing);
    });

    testWidgets('asks how the computer plays once it is chosen', (
      tester,
    ) async {
      await pumpNewGame(tester);

      await tapText(tester, 'The computer');

      expect(find.text('Difficulty'), findsOne);
      expect(find.text('You move'), findsOne);
    });

    testWidgets('starts a game against a friend', (tester) async {
      await pumpNewGame(tester);

      await tapText(tester, 'Start');

      expect(find.text('Game ?'), findsOne);
    });

    testWidgets('starts a game against the computer chosen', (tester) async {
      await pumpNewGame(tester);

      await tapText(tester, 'The computer');
      await tapText(tester, 'Hard');
      await tapText(tester, 'Second');
      await tapText(tester, 'Start');

      expect(find.text('Game ?computer=black&difficulty=hard'), findsOne);
    });
  });
}
