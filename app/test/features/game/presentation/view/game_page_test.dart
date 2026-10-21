import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/game_view.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/game_bloc_factory.dart';

void main() {
  group('GamePage', () {
    testWidgets('starts a game on the standard board', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [BoardColors.light]),
          home: const GamePage(createBloc: createTestGameBloc),
        ),
      );

      expect(find.byType(GameView), findsOne);
      expect(find.byType(BoardSquare), findsNWidgets(25));
      expect(find.text('Player 1 to move'), findsOne);
    });

    testWidgets('picks up the saved game when resuming', (tester) async {
      final repository = InMemoryGameRepository();
      final saved = GameRecord(moves: [Move(const Position(2, 2))]);
      await repository.save(saved);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [BoardColors.light]),
          home: GamePage(
            createBloc: () => createTestGameBloc(repository: repository),
            resume: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DieFace), findsOne);
      expect(find.text('Player 2 to move'), findsOne);
    });
  });
}
