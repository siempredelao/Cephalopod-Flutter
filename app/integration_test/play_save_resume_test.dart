import 'package:cephalopod/app/bootstrap.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:cephalopod/features/home/presentation/view/widgets/continue_card.dart';
import 'package:cephalopod/features/how_to_play/presentation/view/how_to_play_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/board.dart';

/// The one test that runs the real app on a device, with its real storage:
/// play a move, leave the game, start the app again and continue.
///
/// Run it on an emulator or a phone with
/// `flutter test integration_test/play_save_resume_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Starts the app the way `main` does. Showing an empty widget first makes
  /// the app start from nothing, as it does after the phone closes it.
  Future<void> startApp(WidgetTester tester) async {
    runApp(const SizedBox());
    await tester.pump();
    bootstrap(Flavor.prod);
    await tester.pumpAndSettle();
  }

  testWidgets('plays a move, saves the game and resumes it', (tester) async {
    // An earlier run on this device must not leave a game or How to play
    // behind.
    await SharedPreferencesAsync().clear();
    await startApp(tester);

    // A first launch opens How to play over Home.
    expect(find.byType(HowToPlayPage), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ContinueCard), findsNothing);

    // A new game against a friend, and one move.
    await tester.tap(find.widgetWithText(FilledButton, 'New game'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pumpAndSettle();
    expect(diceOnBoard, findsNothing);
    await tester.tap(find.byType(BoardSquare).first);
    await tester.pumpAndSettle();
    expect(diceOnBoard, findsOneWidget);

    // The phone closes the app, and it starts again.
    await startApp(tester);
    expect(find.byType(HowToPlayPage), findsNothing);
    expect(find.byType(ContinueCard), findsOneWidget);

    await tester.tap(find.byType(ContinueCard));
    await tester.pumpAndSettle();
    expect(find.byType(GamePage), findsOneWidget);
    expect(diceOnBoard, findsOneWidget);
  });
}
