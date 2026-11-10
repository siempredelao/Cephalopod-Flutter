import 'package:cephalopod/features/about/about_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/phone.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final address = AboutModule.ruleSheet.toString();
  final opened = <Uri>[];

  setUp(opened.clear);

  /// The link to the rule sheet: the address, as a button.
  Finder link() => find.widgetWithText(TextButton, address);

  group('AboutPage', () {
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

    testWidgets('opens the rule sheet when its link is tapped', (tester) async {
      await pumpApp(
        tester,
        location: '/about',
        linkOpener: (address) async {
          opened.add(address);
          return true;
        },
      );

      await tester.tap(link());
      await tester.pumpAndSettle();

      expect(opened, [AboutModule.ruleSheet]);
      expect(find.textContaining('could not be opened'), findsNothing);
    });

    testWidgets('says so, and shows the address to copy, when it cannot', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: '/about',
        linkOpener: (_) async => false,
      );

      await tester.tap(link());
      await tester.pumpAndSettle();

      expect(find.textContaining('could not be opened'), findsOne);
      expect(find.byType(SelectableText), findsOne);
      expect(find.text(address), findsNWidgets(2));
    });

    testWidgets('speaks Spanish', (tester) async {
      useSmallPhone(tester, const Locale('es', 'ES'));
      await pumpApp(
        tester,
        location: '/about',
        linkOpener: (_) async => false,
      );

      expect(find.text('Versión 1.2.0 (compilación 14)'), findsOne);

      await tester.tap(link());
      await tester.pumpAndSettle();

      expect(find.textContaining('No se pudo abrir el enlace'), findsOne);
    });
  });
}
