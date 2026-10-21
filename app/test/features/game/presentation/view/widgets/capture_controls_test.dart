import 'package:cephalopod/features/game/presentation/view/widgets/capture_controls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<List<String>> pumpControls(
    WidgetTester tester, {
    required bool canConfirm,
  }) async {
    final pressed = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptureControls(
            selectedSum: 4,
            maxSum: 6,
            canConfirm: canConfirm,
            onConfirm: () => pressed.add('capture'),
            onCancel: () => pressed.add('cancel'),
          ),
        ),
      ),
    );
    return pressed;
  }

  group('CaptureControls', () {
    testWidgets('shows the sum picked so far', (tester) async {
      await pumpControls(tester, canConfirm: false);

      expect(find.text('Capture sum: 4 of up to 6'), findsOne);
    });

    testWidgets('captures only a legal set of dice', (tester) async {
      final pressed = await pumpControls(tester, canConfirm: false);

      await tester.tap(find.text('Capture'));

      expect(pressed, isEmpty);
    });

    testWidgets('captures once the dice are a legal set', (tester) async {
      final pressed = await pumpControls(tester, canConfirm: true);

      await tester.tap(find.text('Capture'));

      expect(pressed, ['capture']);
    });

    testWidgets('backs out on cancel', (tester) async {
      final pressed = await pumpControls(tester, canConfirm: false);

      await tester.tap(find.text('Cancel'));

      expect(pressed, ['cancel']);
    });
  });
}
