import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod/features/game/presentation/models/captured_die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/view/effects/particles.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_burst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const player1 = SideUi(player: PlayerUi.one, role: RoleUi.player);
  const player2 = SideUi(player: PlayerUi.two, role: RoleUi.player);

  /// Player 2's die on the second square of the top row.
  const topDie = CapturedDieUi(row: 0, col: 1, owner: player2);

  /// Player 1's die in the middle of the board.
  const middleDie = CapturedDieUi(row: 2, col: 2, owner: player1);

  const halfway = Duration(milliseconds: 250);

  /// A burst of [captured] over a 5 × 5 board of 200 × 200 px, so each
  /// square is 40 px wide.
  Future<void> pumpBurst(
    WidgetTester tester,
    List<CapturedDieUi> captured, {
    bool lessMotion = false,
  }) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: lessMotion),
        child: Theme(
          data: ThemeData(extensions: const [BoardColors.light]),
          child: Center(
            child: SizedBox.square(
              dimension: 200,
              child: CaptureBurst(captured: captured, rows: 5, cols: 5),
            ),
          ),
        ),
      ),
    );
  }

  /// Starts a burst of [captured], from a board where nothing was captured,
  /// and draws its first frame, from which its time is counted.
  Future<void> burst(
    WidgetTester tester,
    List<CapturedDieUi> captured, {
    bool lessMotion = false,
  }) async {
    await pumpBurst(tester, const [], lessMotion: lessMotion);
    await pumpBurst(tester, captured, lessMotion: lessMotion);
    await tester.pump();
  }

  final drawing = find.descendant(
    of: find.byType(CaptureBurst),
    matching: find.byType(CustomPaint),
  );

  /// The pieces of the burst on screen.
  ParticleField piecesOf(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(drawing);
    return (paint.foregroundPainter! as ParticlePainter).field;
  }

  group('CaptureBurst', () {
    testWidgets('draws nothing before anything is captured', (tester) async {
      await pumpBurst(tester, const []);

      expect(drawing, findsNothing);
    });

    testWidgets('bursts when a move captures, and is gone once it is over', (
      tester,
    ) async {
      await burst(tester, const [topDie]);

      await tester.pump(halfway);
      expect(drawing, findsOne);

      // At its end, its pieces have faded away, and on the next frame the
      // burst is gone.
      await tester.pump(halfway);
      expect(drawing, paintsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      expect(drawing, findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    test('lasts as long as the die shrinking away', () {
      expect(CaptureBurst.duration, const Duration(milliseconds: 500));
    });

    testWidgets('sends pieces in both colours of each die out of its square', (
      tester,
    ) async {
      await burst(tester, const [topDie, middleDie]);
      await tester.pump(halfway);

      final pieces = piecesOf(tester).particles;
      const colors = BoardColors.light;

      expect(pieces, hasLength(24));
      expect(
        pieces
            .where((piece) => piece.origin == const Offset(60, 20))
            .map(
              (piece) => piece.color,
            ),
        unorderedEquals([
          ...List.filled(6, colors.whiteDie),
          ...List.filled(6, colors.whiteDieEdge),
        ]),
      );
      expect(
        pieces
            .where((piece) => piece.origin == const Offset(100, 100))
            .map(
              (piece) => piece.color,
            ),
        unorderedEquals([
          ...List.filled(6, colors.blackDie),
          ...List.filled(6, colors.blackDieEdge),
        ]),
      );
    });

    testWidgets('makes its pieces once per burst', (tester) async {
      await burst(tester, const [topDie]);
      await tester.pump(const Duration(milliseconds: 100));
      final early = piecesOf(tester);

      await tester.pump(const Duration(milliseconds: 100));

      expect(piecesOf(tester), same(early));
    });

    testWidgets('bursts the same dice the same way every time', (
      tester,
    ) async {
      await burst(tester, const [topDie]);
      await tester.pump(halfway);
      final first = piecesOf(tester).at(0.5);

      await burst(tester, const [middleDie]);
      await tester.pump(halfway);
      await burst(tester, const [topDie]);
      await tester.pump(halfway);

      expect(piecesOf(tester).at(0.5), first);
    });

    testWidgets('flashes a ring on each square at the start only', (
      tester,
    ) async {
      await burst(tester, const [topDie]);

      await tester.pump(const Duration(milliseconds: 50));
      expect(
        drawing,
        paints..circle(
          x: 60,
          y: 20,
          style: PaintingStyle.stroke,
          color: BoardColors.light.whiteDieEdge.withValues(
            alpha: 1 - 0.1 / 0.35,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(drawing, isNot(paints..circle()));
    });

    testWidgets('plays once for a move, however often it is drawn', (
      tester,
    ) async {
      await burst(tester, const [topDie]);
      await tester.pumpAndSettle();

      // The same dice again, as when the screen changes for a hint.
      await pumpBurst(tester, const [
        CapturedDieUi(row: 0, col: 1, owner: player2),
      ]);
      await tester.pump(const Duration(milliseconds: 100));

      expect(drawing, findsNothing);
    });

    testWidgets('stops at once when the capture is taken back', (
      tester,
    ) async {
      await burst(tester, const [topDie]);
      await tester.pump(const Duration(milliseconds: 100));

      await pumpBurst(tester, const []);

      expect(drawing, findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('does not burst when the device asks for less motion', (
      tester,
    ) async {
      await burst(tester, const [topDie], lessMotion: true);

      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump(const Duration(milliseconds: 100));
      expect(drawing, findsNothing);
    });
  });
}
