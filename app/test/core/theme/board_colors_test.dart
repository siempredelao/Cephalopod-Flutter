import 'package:cephalopod/app/theme.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The WCAG contrast ratio between [a] and [b], from 1 to 21.
double _contrast(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}

/// What WCAG 1.4.11 asks of the parts of a graphic that carry meaning: here,
/// a die's outline, its pips and the rings around marked squares.
const double _graphicContrast = 3;

void main() {
  const light = BoardColors.light;
  const dark = BoardColors.dark;

  group('BoardColors', () {
    test('is on the light and dark themes', () {
      expect(AppTheme.light.extension<BoardColors>(), light);
      expect(AppTheme.dark.extension<BoardColors>(), dark);
    });

    testWidgets('are read from the theme around a widget', (tester) async {
      late BoardColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) {
              colors = BoardColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors, dark);
    });

    test('differ between the themes, except for the dice', () {
      expect(light.board, isNot(dark.board));
      expect(light.square, isNot(dark.square));
      // The tutorial's words name the colours, coral and cream, in both
      // themes.
      expect(light.blackDie, dark.blackDie);
      expect(light.whiteDie, dark.whiteDie);
    });

    final palettes = {'light': light, 'dark': dark};
    for (final MapEntry(key: name, value: colors) in palettes.entries) {
      group('on the $name board', () {
        void expectContrast(String what, Color a, Color b) {
          expect(
            _contrast(a, b),
            greaterThanOrEqualTo(_graphicContrast),
            reason: '$what, in the $name palette',
          );
        }

        test("show each die's outline against its square", () {
          expectContrast('Coral die edge', colors.blackDieEdge, colors.square);
          expectContrast('Cream die edge', colors.whiteDieEdge, colors.square);
        });

        test('show the pips against the die', () {
          expectContrast('Coral die pips', colors.blackPips, colors.blackDie);
          expectContrast('Cream die pips', colors.whitePips, colors.whiteDie);
        });

        test('show every ring against the board', () {
          expectContrast('Last move ring', colors.lastMove, colors.board);
          expectContrast('Capture target', colors.captureTarget, colors.board);
          expectContrast('Capture option', colors.captureOption, colors.board);
          expectContrast('Picked die', colors.captureSelected, colors.board);
        });
      });
    }

    test('copyWith replaces only the colours it is given', () {
      const red = Color(0xFFFF0000);

      final copy = light.copyWith(board: red);

      expect(copy.board, red);
      expect(copy.square, light.square);
      expect(copy.captureSelected, light.captureSelected);
    });

    test('lerp blends every colour towards the other set', () {
      const red = Color(0xFFFF0000);
      final other = light.copyWith(board: red, captureSelected: red);

      final half = light.lerp(other, 0.5);

      expect(half.board, Color.lerp(light.board, red, 0.5));
      expect(half.captureSelected, Color.lerp(light.captureSelected, red, 0.5));
    });

    test('lerp to nothing keeps the colours', () {
      expect(light.lerp(null, 0.5), same(light));
    });
  });
}
