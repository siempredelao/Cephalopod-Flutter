import 'package:cephalopod/core/board/board_thumbnail.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/home/presentation/bloc/saved_game_ui_mapper.dart';
import 'package:cephalopod/features/home/presentation/view/widgets/continue_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../helpers/localized_app.dart';
import '../../../../../helpers/saved_game_summary.dart';

void main() {
  final game = const SavedGameUiMapper().map(savedGameSummary);

  Future<void> pumpCard(
    WidgetTester tester, {
    VoidCallback? onPressed,
    Locale locale = const Locale('en'),
  }) {
    return tester.pumpWidget(
      localizedApp(
        locale: locale,
        Theme(
          data: ThemeData(extensions: const [BoardColors.light]),
          child: Center(
            child: ContinueCard(game: game, onPressed: onPressed ?? () {}),
          ),
        ),
      ),
    );
  }

  group('ContinueCard', () {
    testWidgets('shows the saved board, the opponent and the turn', (
      tester,
    ) async {
      await pumpCard(tester);

      expect(find.byType(BoardThumbnail), findsOne);
      expect(find.text('Continue'), findsOne);
      expect(find.text('vs Computer · Hard'), findsOne);
      expect(
        find.text("Computer's turn · you\u00a01, computer\u00a00"),
        findsOne,
      );
    });

    testWidgets('is in the language on screen', (tester) async {
      await pumpCard(tester, locale: const Locale('es', 'ES'));

      expect(find.text('Continuar'), findsOne);
      expect(find.text('contra el ordenador · Difícil'), findsOne);
      expect(
        find.text('Turno del ordenador · tú\u00a01, ordenador\u00a00'),
        findsOne,
      );
    });

    testWidgets('picks the game up when tapped', (tester) async {
      var taps = 0;
      await pumpCard(tester, onPressed: () => taps++);

      await tester.tap(find.byType(ContinueCard));

      expect(taps, 1);
    });

    testWidgets('is one button for screen readers, saying all of it', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCard(tester);

      expect(
        find.bySemanticsLabel(
          "Continue. vs Computer · Hard. Computer's turn. "
          'You: 1 die. Computer: 0 dice.',
        ),
        findsOne,
      );
      semantics.dispose();
    });
  });
}
