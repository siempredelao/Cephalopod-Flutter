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

const int _size = 5;

/// The dice on the board before Player 1's move. Player 1 can place a die
/// in the middle and capture the 2, the 1 and the 3 around it (2 + 1 + 3 =
/// 6). The 2 and the 3 by the bottom right corner are too far away to
/// matter yet: they are for Player 2's move after it.
final Map<Position, Die> _start = {
  const Position(1, 2): const Die(owner: Player.white, pips: 2),
  const Position(2, 1): const Die(owner: Player.white, pips: 1),
  const Position(2, 3): const Die(owner: Player.black, pips: 3),
  const Position(4, 3): const Die(owner: Player.black, pips: 2),
  const Position(3, 4): const Die(owner: Player.black, pips: 3),
};

/// The two moves the demo shows. Player 1 captures three dice with a 6 in
/// the middle; then Player 2 captures two of Player 1's dice with a 5 in
/// the corner (2 + 3 = 5).
final List<Move> demoMoves = [
  Move(
    const Position(2, 2),
    captures: {
      const Position(1, 2),
      const Position(2, 1),
      const Position(2, 3),
    },
  ),
  Move(
    const Position(4, 4),
    captures: {const Position(4, 3), const Position(3, 4)},
  ),
];

/// The die each move places: the sum of the dice it captures, and the
/// colour of the player who moves.
const List<Die> _placed = [
  Die(owner: Player.black, pips: 6),
  Die(owner: Player.white, pips: 5),
];

/// The position before the demo's first move, for tests to check it and the
/// moves against the rules.
final GameState demoPosition = GameState(
  board: Board(size: _size, dice: _start),
  status: const InProgress(Player.black),
);

/// The demo: an empty board, a position, then for each of the two moves
/// the die that captures with the sum of what it captures and the board
/// after, then round again.
///
/// Every frame holds for longer than a die takes to grow or shrink, so the
/// board has stopped moving before it changes again.
final DemoScript homeDemoScript = _script();

DemoScript _script() {
  final frames = <DemoFrame>[
    (
      board: Board(size: _size),
      marks: const <Position, SquareMark>{},
      hold: const Duration(milliseconds: 600),
    ),
    (
      board: Board(size: _size, dice: _start),
      marks: const <Position, SquareMark>{},
      hold: const Duration(milliseconds: 1500),
    ),
  ];
  var dice = _start;
  for (final (turn, move) in demoMoves.indexed) {
    final withNewDie = {...dice, move.position: _placed[turn]};
    frames.add((
      board: Board(size: _size, dice: withNewDie),
      marks: {
        move.position: SquareMark.captureTarget,
        for (final square in move.captures) square: SquareMark.captureSelected,
      },
      hold: const Duration(milliseconds: 1500),
    ));
    dice = {
      for (final MapEntry(:key, :value) in withNewDie.entries)
        if (!move.captures.contains(key)) key: value,
    };
    final isLast = turn == demoMoves.length - 1;
    frames.add((
      board: Board(size: _size, dice: dice),
      marks: {move.position: SquareMark.lastMove},
      hold: Duration(milliseconds: isLast ? 1800 : 1200),
    ));
  }
  return (frames: frames, still: frames[2]);
}
