import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
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
          home: const GamePage(
            createBloc: createTestGameBloc,
            opening: GameStarted(opponent: FriendOpponent()),
          ),
        ),
      );

      expect(find.byType(GameView), findsOne);
      expect(find.byType(BoardSquare), findsNWidgets(25));
      expect(find.text('Player 1 to move'), findsOne);
    });

    testWidgets('starts a game against the opponent it opens with', (
      tester,
    ) async {
      const computer = ComputerOpponent(
        difficulty: Difficulty.easy,
        player: Player.black,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [BoardColors.light]),
          home: const GamePage(
            createBloc: createTestGameBloc,
            opening: GameStarted(opponent: computer),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The computer plays Black, which moves first.
      expect(find.byType(DieFace), findsOne);
      expect(find.text('Your turn'), findsOne);
    });

    testWidgets('picks up the saved game when resuming', (tester) async {
      final repository = InMemoryGameRepository();
      final record = GameRecord(moves: [Move(const Position(2, 2))]);
      await repository.save((record: record, opponent: const FriendOpponent()));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [BoardColors.light]),
          home: GamePage(
            createBloc: () => createTestGameBloc(repository: repository),
            opening: const GameResumed(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DieFace), findsOne);
      expect(find.text('Player 2 to move'), findsOne);
    });
  });
}
