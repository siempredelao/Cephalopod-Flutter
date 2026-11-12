import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/die_face.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/previews/board_preview_wrapper.dart';
import 'package:cephalopod/core/board/previews/board_square_previews.dart';
import 'package:cephalopod/core/board/previews/die_face_previews.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Builds every preview the way the previewer does, so a preview that stops
/// rendering fails CI instead of the IDE panel.
void main() {
  Future<void> pumpPreview(WidgetTester tester, Widget preview) {
    final wrapped = boardPreviewWrapper(preview);
    final app = MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Center(child: wrapped),
    );
    return tester.pumpWidget(app);
  }

  group('Board previews', () {
    testWidgets('show every die value for both players', (tester) async {
      await pumpPreview(tester, player1DicePreview());
      expect(find.byType(DieFace), findsNWidgets(6));

      await pumpPreview(tester, player2DicePreview());
      expect(find.byType(DieFace), findsNWidgets(6));
    });

    testWidgets('show a square for every mark', (tester) async {
      await pumpPreview(tester, emptySquaresPreview());
      expect(find.byType(BoardSquare), findsNWidgets(SquareMark.values.length));
      expect(find.byType(DieFace), findsNothing);

      await pumpPreview(tester, occupiedSquaresPreview());
      expect(find.byType(DieFace), findsNWidgets(SquareMark.values.length));
    });
  });
}
