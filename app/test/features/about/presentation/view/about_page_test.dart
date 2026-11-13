import 'package:cephalopod/features/about/domain/models/credits.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/phone.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  const copyright = 'Copyright © February 2006 by Mark Steere';
  const moreGames = 'More games by Mark Steere: marksteeregames.com';
  const officialRules = 'Official rules (PDF)';
  const licenses = 'Open-source licenses';
  final opened = <Uri>[];

  setUp(opened.clear);

  /// The link whose label is [label].
  Finder link(String label) => find.widgetWithText(TextButton, label);

  group('AboutPage', () {
    testWidgets('credits the designer, with his copyright and two links', (
      tester,
    ) async {
      await pumpApp(tester, location: '/about');

      expect(find.text('About'), findsOne);
      expect(find.text('Cephalopod was designed by Mark Steere.'), findsOne);
      expect(find.text(copyright), findsOne);
      expect(link(moreGames), findsOne);
      expect(link(officialRules), findsOne);
      // An address to copy shows only when a link does not open.
      expect(find.byType(SelectableText), findsNothing);
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
      expect(find.text(copyright), findsOne);
    });

    testWidgets('opens the website and the rule sheet from their links', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: '/about',
        linkOpener: (address) async {
          opened.add(address);
          return true;
        },
      );

      await tester.tap(link(moreGames));
      await tester.pumpAndSettle();
      await tester.tap(link(officialRules));
      await tester.pumpAndSettle();

      expect(opened, [cephalopodCredits.website, cephalopodCredits.ruleSheet]);
      expect(find.textContaining('could not be opened'), findsNothing);
    });

    testWidgets('opens the list of licenses from its link', (tester) async {
      await pumpApp(tester, location: '/about');

      await tester.tap(link(licenses));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOne);
      expect(find.text('Cephalopod'), findsWidgets);
    });

    testWidgets('goes back to About from the licenses', (tester) async {
      await pumpApp(tester, location: '/about');
      await tester.tap(link(licenses));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsNothing);
      expect(find.text(copyright), findsOne);
    });

    testWidgets('says so, and shows the address to copy, when it cannot', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: '/about',
        linkOpener: (_) async => false,
      );

      await tester.tap(link(officialRules));
      await tester.pumpAndSettle();

      expect(find.textContaining('could not be opened'), findsOne);
      expect(
        find.widgetWithText(SelectableText, '${cephalopodCredits.ruleSheet}'),
        findsOne,
      );
    });

    testWidgets('speaks Spanish, and keeps the copyright in English', (
      tester,
    ) async {
      useSmallPhone(tester, const Locale('es', 'ES'));
      await pumpApp(
        tester,
        location: '/about',
        linkOpener: (_) async => false,
      );

      expect(find.text('Acerca de'), findsOne);
      expect(find.text('Versión 1.2.0 (compilación 14)'), findsOne);
      expect(find.text('Cephalopod fue diseñado por Mark Steere.'), findsOne);
      expect(find.text(copyright), findsOne);
      expect(
        link('Más juegos de Mark Steere: marksteeregames.com'),
        findsOne,
      );
      expect(link('Licencias de código abierto'), findsOne);

      await tester.tap(link('Reglas oficiales (PDF)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No se pudo abrir el enlace'), findsOne);
    });
  });
}
