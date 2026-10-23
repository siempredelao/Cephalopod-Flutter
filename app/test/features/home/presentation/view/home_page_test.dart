import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('HomePage', () {
    Future<void> pumpHome(
      WidgetTester tester, {
      required bool hasGameToContinue,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            createCubit: () =>
                HomeCubit(hasGameToContinue: () async => hasGameToContinue),
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
  });
}
