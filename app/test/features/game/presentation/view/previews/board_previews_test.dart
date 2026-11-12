import 'package:cephalopod/core/board/die_face.dart';
import 'package:cephalopod/core/board/previews/board_preview_wrapper.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/view/previews/game_board_previews.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the game board's previews the way the previewer does, so a preview
/// that stops rendering fails CI instead of the IDE panel.
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

  group('Game board previews', () {
    testWidgets('show a new game, a game in progress and a capture', (
      tester,
    ) async {
      await pumpPreview(tester, newGamePreview());
      expect(find.byType(GameBoard), findsOne);
      expect(find.byType(DieFace), findsNothing);

      await pumpPreview(tester, midGamePreview());
      expect(find.byType(DieFace), findsNWidgets(7));

      await pumpPreview(tester, choosingCapturePreview());
      expect(find.byType(DieFace), findsNWidgets(3));
    });
  });
}
