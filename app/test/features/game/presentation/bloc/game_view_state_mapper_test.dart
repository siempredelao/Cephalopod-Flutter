import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/dice_tally_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/hint_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/played_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/models/captured_die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/computer_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/models/hint_ui.dart';
import 'package:cephalopod/features/game/presentation/models/played_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = GameViewStateMapper();
  const top = Position(0, 2);
  const left = Position(0, 1);
  const right = Position(0, 3);
  const center = Position(2, 2);
  const below = Position(1, 2);
  const placing = TurnPhase.awaitingPlacement();
  const computer = ComputerOpponent(
    difficulty: Difficulty.easy,
    player: Player.white,
  );

  /// Rule sheet Fig. 4, with captures of up to 8 pips: a die on the top
  /// centre square can capture with the 1s either side.
  final figure4 = stateFromAscii(
    '''
    .  w1 .  w1 .
    .  .  b5 .  .
    .  .  .  .  .
    .  .  .  .  .
    .  .  .  .  .
  ''',
    toMove: Player.black,
    config: const GameConfig(maxCaptureSum: 8),
  );

  /// Figure 4's screen against [opponent], waiting for [phase].
  GameViewState map({
    TurnPhase phase = placing,
    Opponent opponent = const FriendOpponent(),
    bool canUndo = false,
    bool canRedo = false,
    PlayedMove? playedMove,
  }) {
    return mapper.map(
      game: figure4,
      opponent: opponent,
      lastMove: Move(center),
      phase: phase,
      highlightLastMove: true,
      canUndo: canUndo,
      canRedo: canRedo,
      playedMove: playedMove,
    );
  }

  group('GameViewStateMapper', () {
    test('draws the board with its marks', () {
      final board = const BoardUiMapper().map(
        game: figure4,
        phase: placing,
        lastMove: Move(center),
        opponent: const FriendOpponent(),
        highlightLastMove: true,
      );

      expect(map().board, board);
    });

    test('says who is to move against the opponent', () {
      expect(map().headline, isA<PlayerToMoveHeadline>());
      expect(map(opponent: computer).headline, isA<PersonToMoveHeadline>());
    });

    test('takes taps while a die can be placed', () {
      final screen = map();

      expect(screen.canTap, isTrue);
      expect(screen.capture, isNull);
    });

    test('R5: shows the capture controls while a capture is chosen', () {
      // Not const: a const set needs elements with primitive equality.
      final screen = map(
        phase: TurnPhase.choosingCapture(
          target: top,
          options: [
            {left, right},
          ],
          selected: {left},
          selectedSum: 1,
        ),
      );

      expect(screen.canTap, isTrue);
      expect(
        screen.capture,
        const CaptureUi(selectedSum: 1, maxSum: 8, canConfirm: false),
      );
    });

    test('takes no taps while the computer thinks', () {
      final screen = map(
        phase: const TurnPhase.computerThinking(),
        opponent: computer,
      );

      expect(screen.canTap, isFalse);
      expect(screen.capture, isNull);
    });

    test('takes no taps once the game is over', () {
      const blackWins = Finished(
        winner: Player.black,
        blackDice: 13,
        whiteDice: 12,
      );

      expect(map(phase: const TurnPhase.gameEnded(blackWins)).canTap, isFalse);
    });

    group('with a hint', () {
      final hintMove = Move(top, captures: {left, right});

      test('offers one only while a die can be placed', () {
        expect(map().canHint, isTrue);
        expect(
          map(phase: const TurnPhase.computerThinking()).canHint,
          isFalse,
        );
        expect(
          map(
            phase: const TurnPhase.gameEnded(
              Finished(winner: Player.black, blackDice: 13, whiteDice: 12),
            ),
          ).canHint,
          isFalse,
        );
        expect(
          map(
            phase: TurnPhase.choosingCapture(
              target: top,
              options: [
                {left, right},
              ],
            ),
          ).canHint,
          isFalse,
        );
      });

      test('says it is looking, and waits for it, while it searches', () {
        final screen = map(
          canUndo: true,
          canRedo: true,
          phase: const TurnPhase.awaitingPlacement(
            hint: HintState.searching(),
          ),
        );

        expect(screen.headline, const HeadlineUi.lookingForHint());
        expect(screen.canTap, isFalse);
        expect(screen.canUndo, isFalse);
        expect(screen.canRedo, isFalse);
        expect(screen.canHint, isFalse);
        expect(screen.hint, isNull);
      });

      test('marks the board and reports it once found', () {
        final phase = TurnPhase.awaitingPlacement(
          hint: HintState.found(hintMove),
        );
        final screen = map(canUndo: true, phase: phase);

        expect(screen.hint, const HintUi(row: 0, col: 2, captures: 2));
        expect(
          screen.board,
          const BoardUiMapper().map(
            game: figure4,
            phase: phase,
            lastMove: Move(center),
            opponent: const FriendOpponent(),
            highlightLastMove: true,
          ),
        );
        expect(screen.headline, isNot(const HeadlineUi.lookingForHint()));
        expect(screen.canTap, isTrue);
        expect(screen.canUndo, isTrue);
        expect(screen.canHint, isFalse);
      });
    });

    test("counts each side's dice on the board", () {
      expect(
        map(opponent: computer).tally,
        const DiceTallyUiMapper().map(figure4, computer),
      );
      expect(map().tally.playerOne.dice, 1);
      expect(map().tally.playerTwo.dice, 2);
    });

    test('reports no played move unless one led to the screen', () {
      expect(map().playedMove, isNull);
    });

    test("reports no computer move after the person's move", () {
      final screen = map(
        playedMove: (move: Move(below), byComputer: false, captured: const {}),
      );

      expect(screen.playedMove, const PlayedMoveUi());
    });

    test('reports the dice a move captured, and whose they were', () {
      final capture = Move(top, captures: {left, right});
      final screen = map(
        playedMove: (
          move: capture,
          byComputer: false,
          captured: {
            left: const Die(owner: Player.white, pips: 1),
            right: const Die(owner: Player.white, pips: 1),
          },
        ),
      );

      const playerTwo = SideUi(player: PlayerUi.two, role: RoleUi.player);
      expect(screen.playedMove?.captured, const [
        CapturedDieUi(row: 0, col: 1, owner: playerTwo),
        CapturedDieUi(row: 0, col: 3, owner: playerTwo),
      ]);
      expect(screen.playedMove?.celebrate, isFalse);
    });

    group('celebrates', () {
      /// A full 3 × 3 board that Black wins, 5 dice to 4.
      final blackWins = stateFromAscii('''
        b1 w1 b1
        w1 b1 w1
        b1 w1 b1
      ''', toMove: Player.black);
      final lastMove = Move(const Position(2, 2));

      /// Whether the screen celebrates the move that ended [blackWins]
      /// against [opponent].
      bool? celebratesAgainst(Opponent opponent) {
        return mapper
            .map(
              game: blackWins,
              opponent: opponent,
              lastMove: lastMove,
              phase: TurnPhase.gameEnded(blackWins.status as Finished),
              highlightLastMove: true,
              canUndo: false,
              canRedo: false,
              playedMove: (
                move: lastMove,
                byComputer: false,
                captured: const {},
              ),
            )
            .playedMove
            ?.celebrate;
      }

      test('the end of a game between two people', () {
        expect(celebratesAgainst(const FriendOpponent()), isTrue);
      });

      test('the person beating the computer', () {
        // The computer plays White, so the person, Black, won.
        expect(celebratesAgainst(computer), isTrue);
      });

      test('not the computer winning', () {
        const computerPlaysBlack = ComputerOpponent(
          difficulty: Difficulty.easy,
          player: Player.black,
        );

        expect(celebratesAgainst(computerPlaysBlack), isFalse);
      });

      test('not a game that goes on', () {
        final screen = map(
          playedMove: (
            move: Move(below),
            byComputer: false,
            captured: const {},
          ),
        );

        expect(screen.playedMove?.celebrate, isFalse);
      });
    });

    test('reports where the computer placed its die and what it shows', () {
      // The 5 on the square below the top centre is the die that moved.
      final screen = map(
        opponent: computer,
        playedMove: (move: Move(below), byComputer: true, captured: const {}),
      );

      expect(
        screen.playedMove?.computer,
        const ComputerMoveUi(row: 1, col: 2, pips: 5),
      );
    });

    test('passes on whether a turn can be undone or redone', () {
      final screen = map(canUndo: true);

      expect(screen.canUndo, isTrue);
      expect(screen.canRedo, isFalse);
      expect(map(canRedo: true).canRedo, isTrue);
    });
  });
}
