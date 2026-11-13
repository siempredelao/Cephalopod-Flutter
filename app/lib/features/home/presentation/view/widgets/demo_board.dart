import 'dart:async';

import 'package:cephalopod/core/board/board_grid.dart';
import 'package:cephalopod/features/home/presentation/models/demo_frame_ui.dart';
import 'package:cephalopod/features/home/presentation/models/demo_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A small board that plays [demo] on a loop: dice grow in, one captures
/// three others and its sum shows, then the other player captures two.
///
/// It is for looking at. Screen readers skip it, it takes no taps, and when
/// the device asks for less motion it stays on one frame. It also stops
/// while another screen is over it.
class DemoBoard extends StatefulWidget {
  const DemoBoard({required this.demo, super.key});

  final DemoUi demo;

  static const double _size = 168;

  @override
  State<DemoBoard> createState() => _DemoBoardState();
}

class _DemoBoardState extends State<DemoBoard> {
  /// The frame on show, as an index in the demo's frames.
  int _index = 0;

  /// Counts down the time the frame on show has left. It runs only while
  /// the demo plays.
  Timer? _timer;

  List<DemoFrameUi> get _frames => widget.demo.frames;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final plays =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (plays) {
      _timer ??= Timer(_frames[_index].hold, _showNextFrame);
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showNextFrame() {
    setState(() => _index = (_index + 1) % _frames.length);
    _timer = Timer(_frames[_index].hold, _showNextFrame);
  }

  @override
  Widget build(BuildContext context) {
    final lessMotion = MediaQuery.disableAnimationsOf(context);
    final frame = lessMotion ? widget.demo.still : _frames[_index];
    return SizedBox.square(
      dimension: DemoBoard._size,
      // An illustration: the title and the buttons say all a screen reader
      // needs, and the squares do nothing when tapped.
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: BoardGrid(
            board: frame.board,
            animateDice: true,
            onSquareTapped: null,
          ),
        ),
      ),
    );
  }
}
