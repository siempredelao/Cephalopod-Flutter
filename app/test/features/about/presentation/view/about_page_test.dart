import 'package:cephalopod/features/about/about_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/phone.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final address = AboutModule.ruleSheet.toString();

  group('AboutPage', () {
    testWidgets('credits the inventor and shows the rule sheet address', (
      tester,
    ) async {
      await pumpApp(tester, location: '/about');

      expect(find.text('About'), findsOne);
      expect(find.textContaining('Mark Steere'), findsOne);
      expect(find.text('Official rules'), findsOne);
      expect(find.widgetWithText(SelectableText, address), findsOne);
    });

    testWidgets('speaks Spanish', (tester) async {
      useSmallPhone(tester, const Locale('es', 'ES'));

      await pumpApp(tester, location: '/about');

      expect(find.text('Acerca de'), findsOne);
      expect(find.text('Reglas oficiales'), findsOne);
      expect(find.widgetWithText(SelectableText, address), findsOne);
    });
  });
}
