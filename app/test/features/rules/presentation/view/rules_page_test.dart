import 'package:cephalopod/core/navigation/external_links.dart';
import 'package:cephalopod/features/rules/presentation/view/rules_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('RulesPage', () {
    testWidgets('explains each part of the rules', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RulesPage()));

      const titles = [
        'The board',
        'Your turn',
        'Capturing',
        'No capture',
        'Winning',
      ];
      for (final title in titles) {
        expect(find.text(title), findsOne);
      }
    });

    testWidgets('links to the official rule sheet', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RulesPage()));

      await tester.scrollUntilVisible(find.text(ruleSheetUrl), 100);

      expect(find.text(ruleSheetUrl), findsOne);
    });
  });
}
