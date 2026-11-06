import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/dialog_page.dart';
import 'package:cephalopod/features/game/presentation/view/new_game_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('NewGameDialog', () {
    /// A page that opens the dialog, by route as the app does, and shows
    /// what the dialog closed with.
    Future<void> pumpOpener(WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const _Opener(),
            routes: [
              GoRoute(
                path: 'new-game',
                name: AppRoute.newGame.name,
                pageBuilder: (_, state) => DialogPage<String>(
                  key: state.pageKey,
                  builder: (_) => const NewGameDialog(),
                ),
              ),
              GoRoute(
                path: 'game',
                name: AppRoute.game.name,
                builder: (_, _) => const SizedBox(),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await _tapText(tester, 'Open');
    }

    testWidgets('offers a friend, with nothing more to choose', (tester) async {
      await pumpOpener(tester);

      expect(find.text('A friend'), findsOne);
      expect(find.text('Difficulty'), findsNothing);
    });

    testWidgets('asks how the computer plays once it is chosen', (
      tester,
    ) async {
      await pumpOpener(tester);

      await _tapText(tester, 'The computer');

      expect(find.text('Difficulty'), findsOne);
      expect(find.text('You move'), findsOne);
    });

    testWidgets('closes with a game against a friend', (tester) async {
      await pumpOpener(tester);

      await _tapText(tester, 'Start');

      expect(find.byType(NewGameDialog), findsNothing);
      expect(find.text('Closed with /game'), findsOne);
    });

    testWidgets('closes with a game against the computer chosen', (
      tester,
    ) async {
      await pumpOpener(tester);

      await _tapText(tester, 'The computer');
      await _tapText(tester, 'Hard');
      await _tapText(tester, 'Second');
      await _tapText(tester, 'Start');

      expect(
        find.text('Closed with /game?computer=black&difficulty=hard'),
        findsOne,
      );
    });

    testWidgets('closes with nothing when cancelled', (tester) async {
      await pumpOpener(tester);

      await _tapText(tester, 'Cancel');

      expect(find.byType(NewGameDialog), findsNothing);
      expect(find.text('Closed with nothing'), findsOne);
    });
  });
}

/// Taps the [text], and waits for what it leads to.
Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

/// Opens the new-game dialog, and shows what it closed with.
class _Opener extends StatefulWidget {
  const _Opener();

  @override
  State<_Opener> createState() => _OpenerState();
}

class _OpenerState extends State<_Opener> {
  String _closedWith = 'not yet';

  Future<void> _open() async {
    final game = await context.pushNamed<String>(AppRoute.newGame.name);
    if (!mounted) return;
    setState(() => _closedWith = game ?? 'nothing');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Closed with $_closedWith'),
          TextButton(onPressed: _open, child: const Text('Open')),
        ],
      ),
    );
  }
}
