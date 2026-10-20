import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

import '../../helpers/result.dart';

void main() {
  final rules = CephalopodRules();
  const center = Position(2, 2);
  const top = Position(0, 2);

  /// Rule sheet Fig. 4: two white 1s either side of the top centre square
  /// and a 5 below it, so three captures are possible there.
  final figure4 = stateFromAscii('''
    .  w1 .  w1 .
    .  .  b5 .  .
    .  .  .  .  .
    .  .  .  .  .
    .  .  .  .  .
  ''', toMove: Player.black);

  group('CephalopodRules.newGame', () {
    test('R1: starts with an empty 5 × 5 board and Black to move', () {
      final state = rules.newGame();

      expect(state.board, Board(size: 5));
      expect(state.status, const InProgress(Player.black));
      expect(state.config, GameConfig.standard);
    });

    test('lets the config choose who moves first', () {
      final state = rules.newGame(const GameConfig(firstPlayer: Player.white));

      expect(state.status, const InProgress(Player.white));
    });

    test('R8: rejects an even board size, which would allow a draw', () {
      expect(
        () => rules.newGame(const GameConfig(boardSize: 4)),
        throwsArgumentError,
      );
      expect(
        () => rules.newGame(const GameConfig(boardSize: -1)),
        throwsArgumentError,
      );
    });

    test('rejects capture limits no die or rule allows', () {
      expect(
        () => rules.newGame(const GameConfig(maxCaptureSum: 7)),
        throwsArgumentError,
      );
      expect(
        () => rules.newGame(const GameConfig(minCaptureDice: 1)),
        throwsArgumentError,
      );
    });
  });

  test('R1: turns alternate between the players', () {
    expect(rules.opponentOf(Player.black), Player.white);
    expect(rules.opponentOf(Player.white), Player.black);
  });

  group('CephalopodRules.apply', () {
    test('R2, R7: a non-capturing die shows 1 and passes the turn', () {
      final next = rules.apply(rules.newGame(), Move(center)).valueOrFail;

      expect(next.board.dice, {
        center: const Die(owner: Player.black, pips: 1),
      });
      expect(next.status, const InProgress(Player.white));
    });

    test('R7: neighbours summing to 7 are not captured (Fig. 5)', () {
      final state = stateFromAscii('''
        .  .  .  .  .
        .  .  .  .  w5
        .  .  .  .  .
        .  .  .  .  b2
        .  .  .  .  .
      ''', toMove: Player.black);

      final next = rules.apply(state, Move(const Position(2, 4))).valueOrFail;

      expect(boardToAscii(next.board), '''
.  .  .  .  .
.  .  .  .  w5
.  .  .  .  b1
.  .  .  .  b2
.  .  .  .  .''');
    });

    test('R6: capturing all four neighbours places their sum (Fig. 3)', () {
      final state = stateFromAscii('''
        .  .  .  .  .
        .  .  w1 .  .
        .  b1 .  w1 .
        .  .  b3 .  .
        .  .  .  .  .
      ''', toMove: Player.black);
      final all = BoardGeometry().neighbours(center, 5).toSet();

      final next = rules.apply(state, Move(center, captures: all)).valueOrFail;

      expect(next.board.dice, {
        center: const Die(owner: Player.black, pips: 6),
      });
    });

    test('R4, R6: dice of either colour can be captured', () {
      final state = stateFromAscii('''
        .  .  .  .  .
        .  .  b2 .  .
        .  w3 .  .  .
        .  .  .  .  .
        .  .  .  .  .
      ''', toMove: Player.black);
      final captures = {const Position(1, 2), const Position(2, 1)};

      final next = rules
          .apply(state, Move(center, captures: captures))
          .valueOrFail;

      expect(next.board.dice, {
        center: const Die(owner: Player.black, pips: 5),
      });
    });

    test('R5: the player chooses which capture to make (Fig. 4)', () {
      final captures = {const Position(0, 1), const Position(0, 3)};

      final next = rules
          .apply(figure4, Move(top, captures: captures))
          .valueOrFail;

      expect(next.board.dice, {
        top: const Die(owner: Player.black, pips: 2),
        const Position(1, 2): const Die(owner: Player.black, pips: 5),
      });
    });

    test('R5: a capture is mandatory where one is possible', () {
      final error = rules.apply(figure4, Move(top)).errorOrFail;

      expect(
        error,
        isA<CaptureRequired>().having(
          (e) => e.options,
          'options',
          hasLength(3),
        ),
      );
    });

    test('R4: refuses captures that are not an option', () {
      final invalid = <Set<Position>>[
        {const Position(0, 1), const Position(0, 3), const Position(1, 2)},
        {const Position(0, 1)},
        {const Position(0, 1), const Position(2, 2)},
        {const Position(0, 1), const Position(4, 4)},
      ];

      for (final captures in invalid) {
        final error = rules
            .apply(figure4, Move(top, captures: captures))
            .errorOrFail;

        expect(
          error,
          isA<InvalidCapture>().having((e) => e.captures, 'captures', captures),
          reason: '$captures',
        );
      }
    });

    test('R4: refuses a capture where none is possible', () {
      final move = Move(center, captures: {const Position(1, 2)});

      final error = rules.apply(rules.newGame(), move).errorOrFail;

      expect(error, isA<InvalidCapture>());
    });

    test('R2: refuses an occupied square', () {
      final state = rules.apply(rules.newGame(), Move(center)).valueOrFail;

      final error = rules.apply(state, Move(center)).errorOrFail;

      expect(
        error,
        isA<SquareOccupied>().having((e) => e.position, 'at', center),
      );
    });

    test('refuses a square outside the board', () {
      const outside = Position(5, 0);

      final error = rules.apply(rules.newGame(), Move(outside)).errorOrFail;

      expect(
        error,
        isA<OutsideBoard>().having((e) => e.position, 'at', outside),
      );
    });

    test('R8: filling the last square ends the game', () {
      final state = stateFromAscii('''
        b6 w6 b6
        w6 .  w6
        b6 w6 b6
      ''', toMove: Player.black);

      final next = rules.apply(state, Move(const Position(1, 1))).valueOrFail;

      expect(
        next.status,
        const Finished(winner: Player.black, blackDice: 5, whiteDice: 4),
      );
    });

    test('R8: a capture on the last square keeps the game going', () {
      final state = stateFromAscii('''
        b6 w1 b6
        w1 .  w6
        b6 w6 b6
      ''', toMove: Player.white);
      final captures = {const Position(0, 1), const Position(1, 0)};

      final next = rules
          .apply(state, Move(const Position(1, 1), captures: captures))
          .valueOrFail;

      expect(next.status, const InProgress(Player.black));
      expect(next.board.dice, hasLength(7), reason: '8 dice, -2, +1');
    });

    test('R8: refuses any move once the game is over', () {
      final state = stateFromAscii('''
        b1 w1 b1
        w1 b1 w1
        b1 w1 b1
      ''', toMove: Player.white);

      expect(rules.apply(state, Move(center)).errorOrFail, isA<GameOver>());
      expect(rules.legalMoves(state), isEmpty);
    });
  });

  group('CephalopodRules.legalMoves', () {
    test('R2: every square is open at the start, none capturing', () {
      final moves = rules.legalMoves(rules.newGame());

      expect(moves, hasLength(25));
      expect(moves.every((move) => move.captures.isEmpty), isTrue);
      expect(moves.first, Move(const Position(0, 0)));
    });

    test('R5: a capture square offers one move per option, none without', () {
      final atTop = rules
          .legalMoves(figure4)
          .where((move) => move.position == top);

      expect(atTop, hasLength(3));
      expect(atTop.every((move) => move.captures.isNotEmpty), isTrue);
    });

    test('every listed move is accepted by apply', () {
      for (final move in rules.legalMoves(figure4)) {
        expect(rules.apply(figure4, move), isA<Ok<GameState, IllegalMove>>());
      }
    });
  });
}
