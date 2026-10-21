import 'package:cephalopod/features/game/presentation/view/previews/board_preview_wrapper.dart';
import 'package:cephalopod/features/game/presentation/view/previews/board_square_previews.dart';
import 'package:cephalopod/features/game/presentation/view/previews/die_face_previews.dart';
import 'package:cephalopod/features/game/presentation/view/previews/game_board_previews.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_mark.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Builds every preview the way the previewer does, so a preview that stops
/// rendering fails CI instead of the IDE panel.
void main() {
  Future<void> pumpPreview(WidgetTester tester, Widget preview) {
    return tester.pumpWidget(
      MaterialApp(home: Center(child: boardPreviewWrapper(preview))),
    );
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
