import 'package:cephalopod/features/game/presentation/view/how_to_play/step_dots.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpDots(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StepDots(count: 6, current: 1)),
      ),
    );
  }

  group('StepDots', () {
    testWidgets('draws a dot per step', (tester) async {
      await pumpDots(tester);

      final dots = find.descendant(
        of: find.byType(StepDots),
        matching: find.byType(DecoratedBox),
      );
      expect(dots, findsNWidgets(6));
    });

    testWidgets('tells screen readers which step is showing', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpDots(tester);

      expect(find.bySemanticsLabel('Step 2 of 6'), findsOne);
      semantics.dispose();
    });
  });
}
