import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = GameViewStateMapper();
  const top = Position(0, 2);
  const left = Position(0, 1);
  const right = Position(0, 3);
  const center = Position(2, 2);
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
  }) {
    return mapper.map(
      game: figure4,
      opponent: opponent,
      lastMove: Move(center),
      phase: phase,
      highlightLastMove: true,
      canUndo: canUndo,
      canRedo: canRedo,
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
          options: [{left, right}],
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

    test('passes on whether a turn can be undone or redone', () {
      final screen = map(canUndo: true);

      expect(screen.canUndo, isTrue);
      expect(screen.canRedo, isFalse);
      expect(map(canRedo: true).canRedo, isTrue);
    });
  });
}
