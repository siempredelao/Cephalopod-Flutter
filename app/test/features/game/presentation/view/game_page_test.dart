import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/game_view.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('GamePage', () {
    testWidgets('starts a game on the standard board', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [BoardColors.light]),
          home: GamePage(rules: CephalopodRules()),
        ),
      );

      expect(find.byType(GameView), findsOne);
      expect(find.byType(BoardSquare), findsNWidgets(25));
      expect(find.text('Black to move'), findsOne);
    });
  });
}
