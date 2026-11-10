import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/headline_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/models/computer_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns the game on screen into the [GameViewState] the game screen draws:
/// the board, the headline, and the capture controls.
final class GameViewStateMapper {
  const GameViewStateMapper({
    this._boardUiMapper = const BoardUiMapper(),
    this._headlineUiMapper = const HeadlineUiMapper(),
  });

  final BoardUiMapper _boardUiMapper;
  final HeadlineUiMapper _headlineUiMapper;

  /// The screen for [game] against [opponent], waiting for [phase]. The
  /// board marks [lastMove] when [highlightLastMove] is on. Whether a turn
  /// can be taken back or played again is the bloc's to say, and so is
  /// [computerMove], the move the computer played to reach this screen, if
  /// it did.
  GameViewState map({
    required GameState game,
    required Opponent opponent,
    required Move? lastMove,
    required TurnPhase phase,
    required bool highlightLastMove,
    required bool canUndo,
    required bool canRedo,
    Move? computerMove,
  }) {
    final boardUi = _boardUiMapper.map(
      game: game,
      phase: phase,
      lastMove: lastMove,
      opponent: opponent,
      highlightLastMove: highlightLastMove,
    );
    final headlineUi = _headlineUiMapper.map(game.status, opponent);
    final captureUi = _captureUiOf(phase, game.config);
    final canTap = _canTapIn(phase);
    return GameViewState(
      board: boardUi,
      headline: headlineUi,
      capture: captureUi,
      computerMove: _computerMoveUiOf(computerMove, game),
      canTap: canTap,
      canUndo: canUndo,
      canRedo: canRedo,
    );
  }

  /// The computer's [move] as the screen reports it: where it placed its
  /// die, and what the die shows now that the move is played in [game].
  ComputerMoveUi? _computerMoveUiOf(Move? move, GameState game) {
    if (move == null) return null;
    final position = move.position;
    return ComputerMoveUi(
      row: position.row,
      col: position.col,
      pips: game.board.dice[position]!.pips,
    );
  }

  /// The capture controls, while a capture is being chosen (rule R5).
  CaptureUi? _captureUiOf(TurnPhase phase, GameConfig config) {
    return switch (phase) {
      ChoosingCapture(:final selectedSum, :final canConfirm) => CaptureUi(
        selectedSum: selectedSum,
        maxSum: config.maxCaptureSum,
        canConfirm: canConfirm,
      ),
      _ => null,
    };
  }

  /// Whether the board takes taps in [phase]: while a die can be placed or a
  /// capture chosen, but not while the computer thinks, nor once the game is
  /// over.
  bool _canTapIn(TurnPhase phase) => switch (phase) {
    AwaitingPlacement() || ChoosingCapture() => true,
    ComputerThinking() || GameEnded() => false,
  };
}
