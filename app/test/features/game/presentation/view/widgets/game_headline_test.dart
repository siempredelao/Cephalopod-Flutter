import 'package:cephalopod/features/game/presentation/models/computer_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/models/hint_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_headline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../helpers/localized_app.dart';

void main() {
  const yourTurn = HeadlineUi.personToMove();

  Future<void> pumpHeadline(
    WidgetTester tester, {
    ComputerMoveUi? computerMove,
    HintUi? hint,
  }) {
    return tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: GameHeadline(
            headline: yourTurn,
            computerMove: computerMove,
            hint: hint,
          ),
        ),
      ),
    );
  }

  group('GameHeadline', () {
    testWidgets('writes the headline, and says it as a live region', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpHeadline(tester);

      expect(find.text('Your turn'), findsOne);
      expect(
        tester.getSemantics(find.text('Your turn')),
        matchesSemantics(label: 'Your turn', isLiveRegion: true),
      );
      semantics.dispose();
    });

    testWidgets('says the hint first, but writes only the headline', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpHeadline(
        tester,
        hint: const HintUi(row: 1, col: 2, captures: 2),
      );

      expect(find.text('Your turn'), findsOne);
      expect(
        tester.getSemantics(find.text('Your turn')),
        matchesSemantics(
          label:
              'Hint: place your die at row 2, column 3, capturing 2 dice. '
              'Your turn',
          isLiveRegion: true,
        ),
      );
      semantics.dispose();
    });
  });
}
