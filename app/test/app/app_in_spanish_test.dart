import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_controls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

/// A small phone's width, in logical pixels. Spanish words run longer than
/// English ones, so this is where a label would first be clipped.
///
/// Tests draw text in the Ahem font, where every letter is as wide as it is
/// tall, about twice the width of a real font's. So a screen that fits here
/// fits on a phone. One that wraps here may not wrap on a phone, which is
/// why wrapped labels are a check by hand, not by test.
const double _phoneWidth = 360;

void main() {
  /// Puts the test on a 360 dp wide phone whose language is Spanish. A
  /// row or column that does not fit its words throws, and the test fails.
  void useSpanishPhone(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(_phoneWidth, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('es', 'ES')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  group('The app in Spanish at phone width', () {
    testWidgets('shows Home, with every button', (tester) async {
      useSpanishPhone(tester);

      await pumpApp(tester);

      expect(find.textContaining('Un juego de dados'), findsOne);
      expect(find.widgetWithText(FilledButton, 'Nueva partida'), findsOne);
      for (final button in ['Cómo se juega', 'Ajustes', 'Acerca de']) {
        expect(find.widgetWithText(OutlinedButton, button), findsOne);
      }
    });

    testWidgets('shows the new-game dialog, with every choice', (
      tester,
    ) async {
      useSpanishPhone(tester);
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Nueva partida'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('El ordenador'));
      await tester.pumpAndSettle();

      for (final words in ['Rival', 'Dificultad', 'Juegas']) {
        expect(find.text(words), findsOne);
      }
      for (final words in ['Un amigo', 'Fácil', 'Media', 'Difícil']) {
        expect(find.text(words), findsOne);
      }
      expect(find.text('Primero'), findsOne);
      expect(find.text('Segundo'), findsOne);
      expect(find.text('Empezar'), findsOne);
      expect(find.text('Cancelar'), findsOne);
    });

    testWidgets('plays a game, with its headline and tooltips', (
      tester,
    ) async {
      useSpanishPhone(tester);
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Nueva partida'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Empezar'));
      await tester.pumpAndSettle();
      expect(find.text('Turno del Jugador 1'), findsOne);
      await tester.tap(find.byKey(const ValueKey((2, 2))));
      await tester.pumpAndSettle();

      expect(find.text('Turno del Jugador 2'), findsOne);
      for (final tooltip in [
        'Cómo se juega',
        'Nueva partida',
        'Deshacer',
        'Rehacer',
      ]) {
        expect(find.byTooltip(tooltip), findsOne);
      }
    });

    testWidgets('shows every page of How to play', (tester) async {
      useSpanishPhone(tester);
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cómo se juega'));
      await tester.pumpAndSettle();

      var pages = 1;
      while (find.text('Siguiente').evaluate().isNotEmpty) {
        await tester.tap(find.widgetWithText(FilledButton, 'Siguiente'));
        await tester.pumpAndSettle();
        pages++;
      }

      expect(pages, greaterThan(1));
      expect(find.text('Llena el tablero para ganar'), findsOne);
      expect(find.widgetWithText(FilledButton, 'Entendido'), findsOne);
    });

    // The controls only show in the middle of a capture, which playing the
    // app by hand takes a long sequence to reach.
    testWidgets('shows the capture controls', (tester) async {
      tester.view
        ..physicalSize = const Size(_phoneWidth, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CaptureControls(
              capture: const CaptureUi(
                selectedSum: 10,
                maxSum: 6,
                canConfirm: false,
              ),
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Suma de la captura: 10 de 6 como máximo'),
        findsOne,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
