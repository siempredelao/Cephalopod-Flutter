import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:material_ui/material_ui.dart';

/// A [die] drawn as a rounded block with its pips on top, in its owner's
/// colours. It fills the space it is given.
class DieFace extends StatelessWidget {
  const DieFace({required this.die, super.key});

  final Die die;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    final (face, edge, pips) = switch (die.owner) {
      Player.black => (colors.blackDie, colors.blackDieEdge, colors.blackPips),
      Player.white => (colors.whiteDie, colors.whiteDieEdge, colors.whitePips),
    };
    return CustomPaint(
      painter: _DiePainter(
        pips: die.pips,
        face: face,
        edge: edge,
        pipColor: pips,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _DiePainter extends CustomPainter {
  const _DiePainter({
    required this.pips,
    required this.face,
    required this.edge,
    required this.pipColor,
  });

  final int pips;
  final Color face;
  final Color edge;
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
  static const double _cornerRadius = 0.16;
  static const double _edgeHeight = 0.08;
  static const double _pipRadius = 0.09;
  static const double _pipSpacing = 0.25;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final body = Alignment.center.inscribe(
      Size.square(side),
      Offset.zero & size,
    );
    final top = Rect.fromLTWH(
      body.left,
      body.top,
      side,
      side * (1 - _edgeHeight),
    );
    final radius = Radius.circular(side * _cornerRadius);
    final pip = Paint()..color = pipColor;

    canvas
      ..drawRRect(RRect.fromRectAndRadius(body, radius), Paint()..color = edge)
      ..drawRRect(RRect.fromRectAndRadius(top, radius), Paint()..color = face);
    for (final (col, row) in _layouts[pips]!) {
      final centre = Offset(
        top.width * _pipSpacing * (col + 1),
        top.height * _pipSpacing * (row + 1),
      );
      canvas.drawCircle(top.topLeft + centre, side * _pipRadius, pip);
    }
  }

  @override
  bool shouldRepaint(_DiePainter oldDelegate) =>
      oldDelegate.pips != pips ||
      oldDelegate.face != face ||
      oldDelegate.edge != edge ||
      oldDelegate.pipColor != pipColor;
}
