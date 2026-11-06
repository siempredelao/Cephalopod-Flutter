import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:collection/collection.dart';

/// The game screen's view model: turns taps into engine moves and works out
/// what the screen shows. The rules stay in the engine; this class only asks
/// it which moves are legal, and plays, undoes and saves them through the
/// use cases.
class GameBloc extends Bloc<GameEvent, GameViewState> {
  GameBloc({
    required this._cephalopodRules,
    required this._startNewGame,
    required this._playMove,
    required this._undoMove,
    required this._resumeGame,
    GameConfig config = GameConfig.standard,
  }) : super(_startOf(_cephalopodRules.newGame(config))) {
    _gameRecord = GameRecord(config: config);
    // Events wait for storage, so they run one at a time, in order: each
    // sees the game the one before it left.
    on<GameEvent>(_onEvent, transformer: _inOrder);
  }

  final CephalopodRules _cephalopodRules;
  final StartNewGame _startNewGame;
  final PlayMove _playMove;
  final UndoMove _undoMove;
  final ResumeGame _resumeGame;

  /// The moves played so far, as saved. The position they reach is
  /// `state.game`.
  late GameRecord _gameRecord;

  /// Who the person faces, as saved.
  Opponent _opponent = const FriendOpponent();

  /// Moves taken back, most recent last, for redo. A new move clears them.
  final List<Move> _undone = [];

  static GameViewState _startOf(GameState game) =>
      GameViewState(game: game, phase: const TurnPhase.awaitingPlacement());

  static Stream<E> _inOrder<E>(Stream<E> events, EventMapper<E> mapper) =>
      events.asyncExpand(mapper);

  /// The game on screen, as the use cases take it.
  CurrentGame get _currentGame {
    return (record: _gameRecord, opponent: _opponent, state: state.game);
  }

  Future<void> _onEvent(GameEvent event, Emitter<GameViewState> emit) async {
    switch (event) {
      case GameStarted(:final config):
        await _start(config, emit);
      case GameResumed():
        await _resume(emit);
      case SquareTapped(:final position):
        await _onSquareTapped(position, emit);
      case CaptureConfirmed():
        await _confirm(emit);
      case CaptureCancelled():
        _cancel(emit);
      case UndoRequested():
        await _undo(emit);
      case RedoRequested():
        await _redo(emit);
    }
  }

  Future<void> _start(GameConfig config, Emitter<GameViewState> emit) async {
    _undone.clear();
    _show(await _startNewGame(config: config), emit);
  }

  Future<void> _resume(Emitter<GameViewState> emit) async {
    final config = _gameRecord.config;
    final game = await _resumeGame() ?? await _startNewGame(config: config);
    _undone.clear();
    _show(game, emit);
  }

  Future<void> _onSquareTapped(
    Position square,
    Emitter<GameViewState> emit,
  ) async {
    switch (state.phase) {
      case AwaitingPlacement():
        await _place(square, emit);
      case final ChoosingCapture phase:
        _pick(phase, square, emit);
      case GameEnded():
        return;
    }
  }

  /// What a tap on [square] does follows from the legal moves there: none
  /// does nothing, one is played at once, and several mean the player
  /// chooses which capture to make (rule R5).
  Future<void> _place(Position square, Emitter<GameViewState> emit) async {
    final moves = [
      for (final move in _cephalopodRules.legalMoves(state.game))
        if (move.position == square) move,
    ];
    switch (moves) {
      case []:
        return;
      case [final move]:
        await _play(move, emit);
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
            (option) => const SetEquality<Position>().equals(option, selected),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(Emitter<GameViewState> emit) async {
    if (state.phase case ChoosingCapture(
      :final target,
      :final selected,
      canConfirm: true,
    )) {
      await _play(Move(target, captures: selected), emit);
    }
  }

  void _cancel(Emitter<GameViewState> emit) {
    if (state.phase is ChoosingCapture) {
      emit(state.copyWith(phase: const TurnPhase.awaitingPlacement()));
    }
  }

  /// Plays [move], which comes from the engine's legal moves, and saves the
  /// game. A new move replaces any moves taken back.
  Future<void> _play(Move move, Emitter<GameViewState> emit) async {
    if (await _playMove(_currentGame, move) case Ok(:final value)) {
      _undone.clear();
      _show(value, emit);
    }
  }

  /// Takes back the last move, if there is one, and remembers it for redo.
  /// A finished game stays finished.
  Future<void> _undo(Emitter<GameViewState> emit) async {
    final moves = _gameRecord.moves;
    if (moves.isEmpty || state.phase is GameEnded) return;
    final game = await _undoMove(_currentGame);
    _undone.add(moves.last);
    _show(game, emit);
  }

  /// Plays again the last move taken back, if there is one.
  Future<void> _redo(Emitter<GameViewState> emit) async {
    if (_undone.isEmpty) return;
    final move = _undone.removeLast();
    if (await _playMove(_currentGame, move) case Ok(:final value)) {
      _show(value, emit);
    }
  }

  /// Shows [game], the result of a use case, and keeps its record and
  /// opponent for the next move.
  void _show(CurrentGame game, Emitter<GameViewState> emit) {
    _gameRecord = game.record;
    _opponent = game.opponent;
    final inProgress = game.state.status is InProgress;
    emit(
      GameViewState(
        game: game.state,
        phase: _phaseOf(game.state),
        lastMove: game.record.moves.lastOrNull,
        canUndo: inProgress && game.record.moves.isNotEmpty,
        canRedo: _undone.isNotEmpty,
      ),
    );
  }

  static TurnPhase _phaseOf(GameState game) => switch (game.status) {
    final Finished result => TurnPhase.gameEnded(result),
    InProgress() => const TurnPhase.awaitingPlacement(),
  };
}
