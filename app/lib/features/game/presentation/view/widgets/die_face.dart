import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:material_ui/material_ui.dart';

/// A [die] drawn as a rounded square with its pips, in its owner's colours.
/// It fills the space it is given.
class DieFace extends StatelessWidget {
  const DieFace({required this.die, super.key});

  final Die die;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    final (face, pips) = switch (die.owner) {
      Player.black => (colors.blackDie, colors.blackPips),
      Player.white => (colors.whiteDie, colors.whitePips),
    };
    return CustomPaint(
      painter: _DiePainter(pips: die.pips, face: face, pipColor: pips),
      child: const SizedBox.expand(),
    );
  }
}

class _DiePainter extends CustomPainter {
  const _DiePainter({
    required this.pips,
    required this.face,
    required this.pipColor,
  });

  final int pips;
  final Color face;
  final Color pipColor;

  /// Where the pips sit for each value, as (column, row) on a 3 × 3 grid.
  static const Map<int, List<(int, int)>> _layouts = {
    1: [(1, 1)],
    2: [(0, 0), (2, 2)],
    3: [(0, 0), (1, 1), (2, 2)],
    4: [(0, 0), (2, 0), (0, 2), (2, 2)],
    5: [(0, 0), (2, 0), (1, 1), (0, 2), (2, 2)],
    6: [(0, 0), (2, 0), (0, 1), (2, 1), (0, 2), (2, 2)],
  };

  // Sizes as fractions of the die's side.
  static const double _cornerRadius = 0.18;
  static const double _edgeWidth = 0.04;
  static const double _pipRadius = 0.08;
  static const double _pipSpacing = 0.25;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final body = Alignment.center.inscribe(
      Size.square(side),
      Offset.zero & size,
    );
    final rounded = RRect.fromRectAndRadius(
      body,
      Radius.circular(side * _cornerRadius),
    );
    final edge = Paint()
      ..color = pipColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * _edgeWidth;
    final pip = Paint()..color = pipColor;

    canvas
      ..drawRRect(rounded, Paint()..color = face)
      ..drawRRect(rounded, edge);
    for (final (col, row) in _layouts[pips]!) {
      final centre = Offset(col + 1.0, row + 1.0) * (side * _pipSpacing);
      canvas.drawCircle(body.topLeft + centre, side * _pipRadius, pip);
    }
  }

  @override
  bool shouldRepaint(_DiePainter oldDelegate) =>
      oldDelegate.pips != pips ||
      oldDelegate.face != face ||
      oldDelegate.pipColor != pipColor;
}
