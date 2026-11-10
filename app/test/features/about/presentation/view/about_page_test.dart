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

    testWidgets('shows the version and build number under the title', (
      tester,
    ) async {
      await pumpApp(tester, location: '/about');

      expect(find.text('Version 1.2.0 (build 14)'), findsOne);
    });

    testWidgets('shows no version when it cannot be known', (tester) async {
      await pumpApp(
        tester,
        location: '/about',
        appVersionSource: () async => null,
      );

      expect(find.textContaining('Version'), findsNothing);
      expect(find.textContaining('Mark Steere'), findsOne);
    });

    testWidgets('speaks Spanish', (tester) async {
      useSmallPhone(tester, const Locale('es', 'ES'));

      await pumpApp(tester, location: '/about');

      expect(find.text('Versión 1.2.0 (compilación 14)'), findsOne);
      expect(find.text('Acerca de'), findsOne);
      expect(find.text('Reglas oficiales'), findsOne);
      expect(find.widgetWithText(SelectableText, address), findsOne);
    });
  });
}
