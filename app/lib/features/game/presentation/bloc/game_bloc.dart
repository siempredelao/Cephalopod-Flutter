import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:collection/collection.dart';

/// The game screen's view model: turns taps into engine moves and works out
/// what the screen shows. The rules stay in the engine; this class only asks
/// it which moves are legal and plays them.
class GameBloc extends Bloc<GameEvent, GameViewState> {
  GameBloc({required this._rules, GameConfig config = GameConfig.standard})
    : super(_startOf(_rules.newGame(config))) {
    on<GameStarted>(
      (event, emit) => emit(_startOf(_rules.newGame(event.config))),
    );
    on<SquareTapped>(_onSquareTapped);
    on<CaptureConfirmed>(_onCaptureConfirmed);
    on<CaptureCancelled>(_onCaptureCancelled);
  }

  final CephalopodRules _rules;

  static const SetEquality<Position> _sameSquares = SetEquality<Position>();

  static GameViewState _startOf(GameState game) =>
      GameViewState(game: game, phase: const TurnPhase.awaitingPlacement());

  void _onSquareTapped(SquareTapped event, Emitter<GameViewState> emit) {
    switch (state.phase) {
      case AwaitingPlacement():
        _place(event.position, emit);
      case final ChoosingCapture phase:
        _pick(phase, event.position, emit);
      case GameEnded():
        return;
    }
  }

  /// What a tap on [square] does follows from the legal moves there: none
  /// does nothing, one is played at once, and several mean the player
  /// chooses which capture to make (rule R5).
  void _place(Position square, Emitter<GameViewState> emit) {
    final moves = [
      for (final move in _rules.legalMoves(state.game))
        if (move.position == square) move,
    ];
    switch (moves) {
      case []:
        return;
      case [final move]:
        _play(move, emit);
      case _:
        emit(
          state.copyWith(
            phase: TurnPhase.choosingCapture(
              target: square,
              options: [for (final move in moves) move.captures],
            ),
          ),
        );
    }
  }

  /// Adds the die on [square] to the capture, or takes it out again. Only
  /// dice that belong to some capture option can be picked.
  void _pick(
    ChoosingCapture phase,
    Position square,
    Emitter<GameViewState> emit,
  ) {
    if (!phase.options.any((option) => option.contains(square))) return;
    final selected = phase.selected.contains(square)
        ? phase.selected.difference({square})
        : {...phase.selected, square};
    final dice = state.game.board.dice;
    emit(
      state.copyWith(
        phase: phase.copyWith(
          selected: selected,
          selectedSum: selected.map((picked) => dice[picked]?.pips ?? 0).sum,
          canConfirm: phase.options.any(
            (option) => _sameSquares.equals(option, selected),
          ),
        ),
      ),
    );
  }

  void _onCaptureConfirmed(
    CaptureConfirmed event,
    Emitter<GameViewState> emit,
  ) {
    if (state.phase case ChoosingCapture(
      :final target,
      :final selected,
      canConfirm: true,
    )) {
      _play(Move(target, captures: selected), emit);
    }
  }

  void _onCaptureCancelled(
    CaptureCancelled event,
    Emitter<GameViewState> emit,
  ) {
    if (state.phase is ChoosingCapture) {
      emit(state.copyWith(phase: const TurnPhase.awaitingPlacement()));
    }
  }

  /// Plays [move], which comes from the engine's legal moves, and moves on
  /// to the next phase.
  void _play(Move move, Emitter<GameViewState> emit) {
    if (_rules.apply(state.game, move) case Ok(value: final next)) {
      emit(GameViewState(game: next, phase: _phaseOf(next), lastMove: move));
    }
  }

  static TurnPhase _phaseOf(GameState game) => switch (game.status) {
    final Finished result => TurnPhase.gameEnded(result),
    InProgress() => const TurnPhase.awaitingPlacement(),
  };
}
