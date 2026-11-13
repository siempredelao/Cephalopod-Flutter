import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/die_face.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/square_ring.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_script.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_ui_mapper.dart';
import 'package:cephalopod/features/home/presentation/view/widgets/demo_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../helpers/localized_app.dart';

void main() {
  final demo = const DemoUiMapper().map(homeDemoScript);
  final [empty, position, capture1, after1, capture2, after2] =
      homeDemoScript.frames;

  Widget app({bool tickersEnabled = true}) {
    return localizedApp(
      Theme(
        data: ThemeData(extensions: const [BoardColors.light]),
        child: TickerMode(
          enabled: tickersEnabled,
          child: Center(child: DemoBoard(demo: demo)),
        ),
      ),
    );
  }

  /// The time a die takes to grow or shrink, and a little more, so it has
  /// finished: an animation starts counting at the frame after the one that
  /// begins it.
  const settle = Duration(milliseconds: 550);

  /// Lets a frame's [hold] pass, which shows the next frame, and then the
  /// time it takes to settle.
  Future<void> showNextFrame(WidgetTester tester, Duration hold) async {
    await tester.pump(hold);
    await tester.pump();
    await tester.pump(settle);
  }

  /// What is left of a frame's [hold] after the frame has settled.
  Duration restOf(Duration hold) => hold - settle;

  int dice() => find.byType(DieFace).evaluate().length;

  group('DemoBoard', () {
    testWidgets('starts with an empty board', (tester) async {
      await tester.pumpWidget(app());

      expect(dice(), 0);
    });

    testWidgets('plays both captures, one frame after another', (
      tester,
    ) async {
      await tester.pumpWidget(app());

      await showNextFrame(tester, empty.hold);
      expect(dice(), position.board.dice.length);

      await showNextFrame(tester, restOf(position.hold));
      expect(dice(), capture1.board.dice.length);

      await showNextFrame(tester, restOf(capture1.hold));
      expect(dice(), after1.board.dice.length);

      await showNextFrame(tester, restOf(after1.hold));
      expect(dice(), capture2.board.dice.length);

      await showNextFrame(tester, restOf(capture2.hold));
      expect(dice(), after2.board.dice.length);
    });

    testWidgets('goes round again, to the empty board', (tester) async {
      await tester.pumpWidget(app());
      await showNextFrame(tester, empty.hold);
      await showNextFrame(tester, restOf(position.hold));
      await showNextFrame(tester, restOf(capture1.hold));
      await showNextFrame(tester, restOf(after1.hold));
      await showNextFrame(tester, restOf(capture2.hold));

      await showNextFrame(tester, restOf(after2.hold));

      expect(dice(), 0);
    });

    testWidgets('rings the capture while it happens', (tester) async {
      await tester.pumpWidget(app());
      await showNextFrame(tester, empty.hold);
      expect(
        tester
            .widgetList<SquareRing>(find.byType(SquareRing))
            .map((ring) => ring.mark)
            .toSet(),
        {SquareMark.none},
      );

      await showNextFrame(tester, restOf(position.hold));

      final marks = tester
          .widgetList<SquareRing>(find.byType(SquareRing))
          .map((ring) => ring.mark)
          .toList();
      expect(
        marks.where((mark) => mark == SquareMark.captureTarget),
        hasLength(1),
      );
      expect(
        marks.where((mark) => mark == SquareMark.captureSelected),
        hasLength(3),
      );
    });

    testWidgets(
      'stands still on the first capture when asked for less motion',
      (
        tester,
      ) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );

        await tester.pumpWidget(app());
        expect(dice(), capture1.board.dice.length);

        await tester.pump(const Duration(seconds: 30));

        expect(dice(), capture1.board.dice.length);
      },
    );

    testWidgets('waits while another screen covers it, then goes on', (
      tester,
    ) async {
      await tester.pumpWidget(app(tickersEnabled: false));

      await tester.pump(const Duration(seconds: 30));
      expect(dice(), 0);

      await tester.pumpWidget(app());
      await showNextFrame(tester, empty.hold);
      expect(dice(), position.board.dice.length);
    });

    testWidgets('is skipped by screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app());

      expect(find.bySemanticsLabel(RegExp('Row')), findsNothing);
      expect(find.byType(BoardSquare), findsNWidgets(25));
      semantics.dispose();
    });

    testWidgets('takes no taps', (tester) async {
      await tester.pumpWidget(app());

      final squares = find.byType(BoardSquare);
      expect(
        find.ancestor(of: squares.first, matching: find.byType(IgnorePointer)),
        findsWidgets,
      );
    });
  });
}
