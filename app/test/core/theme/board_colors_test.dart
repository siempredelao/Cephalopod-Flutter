import 'package:cephalopod/app/theme.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const light = BoardColors.light;
  const dark = BoardColors.dark;

  group('BoardColors', () {
    test('is on the light and dark themes', () {
      expect(AppTheme.light.extension<BoardColors>(), light);
      expect(AppTheme.dark.extension<BoardColors>(), dark);
    });

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
