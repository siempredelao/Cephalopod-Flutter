import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/headline_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
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
  /// can be taken back or played again is the bloc's to say.
  GameViewState map({
    required GameState game,
    required Opponent opponent,
    required Move? lastMove,
    required TurnPhase phase,
    required bool highlightLastMove,
    required bool canUndo,
    required bool canRedo,
  }) {
    final boardUi = _boardUiMapper.map(
      game: game,
      phase: phase,
      lastMove: lastMove,
      opponent: opponent,
      highlightLastMove: highlightLastMove,
    );
    return GameViewState(
      board: boardUi,
      headline: _headlineUiMapper.map(game.status, opponent),
      capture: _captureUiOf(phase, game.config),
      canTap: phase is AwaitingPlacement || phase is ChoosingCapture,
      canUndo: canUndo,
      canRedo: canRedo,
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
}
