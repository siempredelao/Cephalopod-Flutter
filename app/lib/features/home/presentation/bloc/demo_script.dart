import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// One moment of Home's demo: the `board` on show, the `marks` that make
/// squares stand out on it, and how long it `hold`s before the next moment.
///
/// A Dart record, so it is plain data with value equality.
typedef DemoFrame = ({
  Board board,
  Map<Position, SquareMark> marks,
  Duration hold,
});

/// The demo Home plays on a loop: the `frames` in order, and which of them
/// is the `still` one, shown alone when the device asks for less motion.
typedef DemoScript = ({List<DemoFrame> frames, DemoFrame still});

const int _size = 3;
const Position _target = Position(1, 1);
const Position _above = Position(0, 1);
const Position _left = Position(1, 0);
const Position _right = Position(1, 2);
const Position _far = Position(2, 2);

/// The dice a Player 1 move on [_target] captures: the three dice around it
/// that add up to 6.
final Set<Position> _captured = {_above, _left, _right};

/// The dice on the board before the move. Player 1's die, on the board's
/// middle square, can capture the 2, the 1 and the 3 around it (2 + 1 + 3 =
/// 6). The 4 in the corner is too far away to matter.
final Map<Position, Die> _before = {
  _above: const Die(owner: Player.white, pips: 2),
  _left: const Die(owner: Player.white, pips: 1),
  _right: const Die(owner: Player.black, pips: 3),
  _far: const Die(owner: Player.white, pips: 4),
};

/// Player 1's new die: the sum of what it captures.
const Die _placed = Die(owner: Player.black, pips: 6);

/// The position before the demo's move, for tests to check it against the
/// rules.
final GameState demoPosition = GameState(
  board: Board(size: _size, dice: _before),
  status: const InProgress(Player.black),
  config: const GameConfig(boardSize: _size),
);

/// The move the demo shows.
final Move demoMove = Move(_target, captures: _captured);

/// The demo: an empty board, a position, the die that captures three dice
/// with the sum of them, and the board after, then round again.
///
/// Every frame holds for longer than a die takes to grow or shrink, so the
/// board has stopped moving before it changes again.
final DemoScript homeDemoScript = _script();

DemoScript _script() {
  final empty = (
    board: Board(size: _size),
    marks: const <Position, SquareMark>{},
    hold: const Duration(milliseconds: 600),
  );
  final position = (
    board: Board(size: _size, dice: _before),
    marks: const <Position, SquareMark>{},
    hold: const Duration(milliseconds: 1500),
  );
  final capture = (
    board: Board(size: _size, dice: {..._before, _target: _placed}),
    marks: {
      _target: SquareMark.captureTarget,
      for (final square in _captured) square: SquareMark.captureSelected,
    },
    hold: const Duration(milliseconds: 1500),
  );
  final after = (
    board: Board(
      size: _size,
      dice: {
        for (final MapEntry(:key, :value) in _before.entries)
          if (!_captured.contains(key)) key: value,
        _target: _placed,
      },
    ),
    marks: {_target: SquareMark.lastMove},
    hold: const Duration(milliseconds: 1800),
  );
  return (frames: [empty, position, capture, after], still: capture);
}
