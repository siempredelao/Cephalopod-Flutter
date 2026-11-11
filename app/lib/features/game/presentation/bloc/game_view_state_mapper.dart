import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/dice_tally_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/headline_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/hint_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/played_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/models/computer_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/hint_ui.dart';
import 'package:cephalopod/features/game/presentation/models/played_move_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns the game on screen into the [GameViewState] the game screen draws:
/// the board, the headline, each side's dice count, and the capture
/// controls.
final class GameViewStateMapper {
  const GameViewStateMapper({
    this._boardUiMapper = const BoardUiMapper(),
    this._headlineUiMapper = const HeadlineUiMapper(),
    this._diceTallyUiMapper = const DiceTallyUiMapper(),
  });

  final BoardUiMapper _boardUiMapper;
  final HeadlineUiMapper _headlineUiMapper;
  final DiceTallyUiMapper _diceTallyUiMapper;

  /// The screen for [game] against [opponent], waiting for [phase]. The
  /// board marks [lastMove] when [highlightLastMove] is on. Whether a turn
  /// can be taken back or played again is the bloc's to say. So is
  /// [playedMove], the move just played that led here, if one did.
  ///
  /// While a die is to be placed, the [phase] carries a hint. While it is
  /// searched for, the board takes no taps and the headline says so, and
  /// turns cannot be taken back or played again; once found, it marks the
  /// board. A hint can be asked for only while a die can be placed and none
  /// is shown or searched for.
  GameViewState map({
    required GameState game,
    required Opponent opponent,
    required Move? lastMove,
    required TurnPhase phase,
    required bool highlightLastMove,
    required bool canUndo,
    required bool canRedo,
    PlayedMove? playedMove,
  }) {
    final hint = _getHint(phase);
    final hintMove = switch (hint) {
      HintFound(:final move) => move,
      NoHint() || HintSearching() => null,
    };
    final searching = hint is HintSearching;
    final boardUi = _boardUiMapper.map(
      game: game,
      phase: phase,
      lastMove: lastMove,
      opponent: opponent,
      highlightLastMove: highlightLastMove,
    );
    final headlineUi = _headlineUiMapper.map(game.status, opponent, hint);
    final captureUi = _captureUiOf(phase, game.config);
    final canTap = _canTapIn(phase);
    return GameViewState(
      board: boardUi,
      headline: headlineUi,
      tally: _diceTallyUiMapper.map(game, opponent),
      capture: captureUi,
      playedMove: _playedMoveUiOf(playedMove, game),
      canTap: canTap,
      // Undo and redo would only wait for the search to end.
      canUndo: canUndo && !searching,
      canRedo: canRedo && !searching,
      hint: hintMove == null ? null : _hintUiOf(hintMove),
      canHint: phase is AwaitingPlacement && hint is NoHint,
    );
  }

  HintState _getHint(TurnPhase phase) => switch (phase) {
    AwaitingPlacement(:final hint) => hint,
    ChoosingCapture() ||
    ComputerThinking() ||
    GameEnded() => const HintState.none(),
  };

  /// The hinted [move] as a screen reader says it.
  HintUi _hintUiOf(Move move) => HintUi(
    row: move.position.row,
    col: move.position.col,
    captures: move.captures.length,
  );

  /// The move just played, as the screen shows it, if one led to [game].
  PlayedMoveUi? _playedMoveUiOf(PlayedMove? playedMove, GameState game) {
    if (playedMove == null) return null;
    final (:move, :byComputer) = playedMove;
    return PlayedMoveUi(
      computer: byComputer ? _computerMoveUiOf(move, game) : null,
    );
  }

  /// The computer's [move] as the screen reports it: where it placed its
  /// die, and what the die shows now that the move is played in [game].
  ComputerMoveUi _computerMoveUiOf(Move move, GameState game) {
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
  /// capture chosen, but not while a hint is searched for, the computer
  /// thinks, nor once the game is over.
  bool _canTapIn(TurnPhase phase) => switch (phase) {
    AwaitingPlacement(hint: HintSearching()) => false,
    AwaitingPlacement() || ChoosingCapture() => true,
    ComputerThinking() || GameEnded() => false,
  };
}
