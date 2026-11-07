import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/board_ui.dart';
import 'package:cephalopod/features/game/presentation/models/die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = BoardUiMapper();
  const top = Position(0, 2);
  const left = Position(0, 1);
  const right = Position(0, 3);
  const below = Position(1, 2);
  const placing = TurnPhase.awaitingPlacement();

  /// Rule sheet Fig. 4: a die on the top centre square can capture with the
  /// 1s either side and the 5 below.
  final figure4 = stateFromAscii('''
    .  w1 .  w1 .
    .  .  b5 .  .
    .  .  .  .  .
    .  .  .  .  .
    .  .  .  .  .
  ''', toMove: Player.black);

  /// Figure 4's board, against [opponent], marked for [phase].
  BoardUi map({
    TurnPhase phase = placing,
    Move? lastMove,
    Opponent opponent = const FriendOpponent(),
    bool highlightLastMove = true,
  }) {
    return mapper.map(
      game: figure4,
      phase: phase,
      lastMove: lastMove,
      opponent: opponent,
      highlightLastMove: highlightLastMove,
    );
  }

  SquareUi squareAt(BoardUi board, Position position) {
    return board.rows[position.row][position.col];
  }

  group('BoardUiMapper', () {
    test('lays the squares out row by row', () {
      final board = map();

      expect(board.rows, hasLength(5));
      for (final (row, squares) in board.rows.indexed) {
        expect(squares, hasLength(5));
        for (final (col, square) in squares.indexed) {
          expect((square.row, square.col), (row, col));
        }
      }
    });

    test('puts each die on its square, with its side', () {
      final board = map();

      expect(
        squareAt(board, below).die,
        const DieUi(
          pips: 5,
          owner: SideUi(player: PlayerUi.one, role: RoleUi.player),
        ),
      );
      expect(squareAt(board, left).die?.owner.player, PlayerUi.two);
      expect(squareAt(board, top).die, isNull);
    });

    test('names the sides against the computer', () {
      const computer = ComputerOpponent(
        difficulty: Difficulty.easy,
        player: Player.white,
      );

      final board = map(opponent: computer);

      expect(squareAt(board, left).die?.owner.role, RoleUi.computer);
      expect(squareAt(board, below).die?.owner.role, RoleUi.you);
    });

    test('marks the last move', () {
      final board = map(lastMove: Move(below));

      expect(squareAt(board, below).mark, SquareMark.lastMove);
      expect(squareAt(board, top).mark, SquareMark.none);
    });

    test('leaves the last move unmarked when told to', () {
      final board = map(lastMove: Move(below), highlightLastMove: false);

      expect(squareAt(board, below).mark, SquareMark.none);
    });

    test('R5: marks the target and the dice that can be picked', () {
      final board = map(
        lastMove: Move(below),
        // Not const: a const set needs elements with primitive equality.
        phase: TurnPhase.choosingCapture(
          target: top,
          options: [
            {left, right},
            {left, below},
            {right, below},
          ],
          selected: {left},
        ),
      );

      expect(squareAt(board, top).mark, SquareMark.captureTarget);
      expect(squareAt(board, left).mark, SquareMark.captureSelected);
      expect(squareAt(board, right).mark, SquareMark.captureOption);
      expect(squareAt(board, below).mark, SquareMark.captureOption);
      expect(squareAt(board, const Position(4, 4)).mark, SquareMark.none);
    });
  });
}
