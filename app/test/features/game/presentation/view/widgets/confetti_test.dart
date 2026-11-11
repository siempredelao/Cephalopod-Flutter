import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/view/effects/particles.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/confetti.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final theme = ThemeData(extensions: const [BoardColors.light]);

  /// The confetti over a 300 × 600 screen, falling when [play] is on.
  Future<void> pumpConfetti(
    WidgetTester tester, {
    required bool play,
    bool lessMotion = false,
    ThemeData? themeData,
  }) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: lessMotion),
        child: Theme(
          data: themeData ?? theme,
          child: Center(
            child: SizedBox(
              width: 300,
              height: 600,
              child: Confetti(play: play),
            ),
          ),
        ),
      ),
    );
  }

  /// Turns the confetti on, and draws its first frame, from which its time
  /// is counted.
  Future<void> celebrate(WidgetTester tester, {bool lessMotion = false}) async {
    await pumpConfetti(tester, play: false, lessMotion: lessMotion);
    await pumpConfetti(tester, play: true, lessMotion: lessMotion);
    await tester.pump();
  }

  final drawing = find.descendant(
    of: find.byType(Confetti),
    matching: find.byType(CustomPaint),
  );

  /// The pieces falling on screen.
  ParticleField piecesOf(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(drawing);
    return (paint.painter! as ParticlePainter).field;
  }

  group('Confetti', () {
    testWidgets('draws nothing while there is nothing to celebrate', (
      tester,
    ) async {
      await pumpConfetti(tester, play: false);

      expect(drawing, findsNothing);
    });

    testWidgets('falls for 3 seconds, once, when a win comes', (tester) async {
      await celebrate(tester);

      await tester.pump(const Duration(milliseconds: 1500));
      expect(drawing, findsOne);

      // At its end, its pieces have faded away, and on the next frame the
      // confetti is gone.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(drawing, paintsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      expect(drawing, findsNothing);
      expect(tester.hasRunningAnimations, isFalse);

      // Still celebrating, as the screen changes: it does not fall again.
      await pumpConfetti(tester, play: true);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('throws 150 pieces in the dice and theme colours', (
      tester,
    ) async {
      await celebrate(tester);
      await tester.pump(const Duration(milliseconds: 100));

      final pieces = piecesOf(tester).particles;
      const board = BoardColors.light;
      final scheme = theme.colorScheme;

      expect(pieces, hasLength(150));
      expect(
        pieces.map((piece) => piece.color).toSet(),
        {
          board.blackDie,
          board.whiteDie,
          board.lastMove,
          board.hintTarget,
          scheme.primary,
          scheme.tertiary,
        },
      );
      for (final piece in pieces) {
        expect(piece.origin.dx, inInclusiveRange(0, 300));
        expect(piece.origin.dy, inInclusiveRange(-300, 0));
      }
    });

    testWidgets('makes its pieces once per fall', (tester) async {
      await celebrate(tester);
      await tester.pump(const Duration(milliseconds: 100));
      final early = piecesOf(tester);

      await pumpConfetti(tester, play: true);
      await tester.pump(const Duration(milliseconds: 100));

      expect(piecesOf(tester), same(early));
    });

    testWidgets('makes its pieces again in a new theme', (tester) async {
      await celebrate(tester);
      await tester.pump(const Duration(milliseconds: 100));

      await pumpConfetti(
        tester,
        play: true,
        themeData: ThemeData(
          brightness: Brightness.dark,
          extensions: const [BoardColors.dark],
        ),
      );

      expect(
        piecesOf(tester).particles.map((piece) => piece.color),
        contains(BoardColors.dark.lastMove),
      );
    });

    testWidgets('stops at once when a new game starts', (tester) async {
      await celebrate(tester);
      await tester.pump(const Duration(milliseconds: 500));

      await pumpConfetti(tester, play: false);

      expect(drawing, findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('does not fall when the device asks for less motion', (
      tester,
    ) async {
      await celebrate(tester, lessMotion: true);

      expect(drawing, findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
