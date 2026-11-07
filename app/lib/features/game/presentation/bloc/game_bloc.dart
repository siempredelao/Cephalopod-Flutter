import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/request_agent_move.dart';
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
/// use cases. Against the computer, it lets the computer play its turns.
class GameBloc extends Bloc<GameEvent, GameViewState> {
  /// Shows a new game under [config] until the opening event replaces it,
  /// or the given [position], which tests use to start mid-game.
  GameBloc({
    required this._cephalopodRules,
    required this._startNewGame,
    required this._playMove,
    required this._undoMove,
    required this._resumeGame,
    required this._requestAgentMove,
    GameConfig config = GameConfig.standard,
    GameState? position,
  }) : super(_startOf(position ?? _cephalopodRules.newGame(config))) {
    _currentGame = (
      record: GameRecord(config: config),
      opponent: const FriendOpponent(),
      state: state.game,
    );
    // Events wait for storage, so they run one at a time, in order: each
    // sees the game the one before it left.
    on<GameEvent>(_onEvent, transformer: _inOrder);
  }

  final CephalopodRules _cephalopodRules;
  final StartNewGame _startNewGame;
  final PlayMove _playMove;
  final UndoMove _undoMove;
  final ResumeGame _resumeGame;
  final RequestAgentMove _requestAgentMove;

  /// The game on screen, as the use cases take and give it. The bloc keeps
  /// it here rather than reading it back from its state, which only
  /// describes the screen.
  late CurrentGame _currentGame;

  /// What the screen is waiting for.
  TurnPhase _turnPhase = const TurnPhase.awaitingPlacement();

  /// Moves taken back, most recent last, for redo. A new move clears them.
  final List<Move> _undone = [];

  /// How many moves one undo or redo covers: one against a friend; against
  /// the computer, the person's move and the computer's reply, so the
  /// person is to move again.
  int get _movesPerUndo => switch (_currentGame.opponent) {
    FriendOpponent() => 1,
    ComputerOpponent() => 2,
  };

  static GameViewState _startOf(GameState game) =>
      GameViewState(game: game, phase: const TurnPhase.awaitingPlacement());

  static Stream<E> _inOrder<E>(Stream<E> events, EventMapper<E> mapper) =>
      events.asyncExpand(mapper);

  /// Whether a turn can be taken back: there is one, and neither the
  /// computer is thinking nor the game is over.
  bool get _canUndo => switch (_turnPhase) {
    AwaitingPlacement() || ChoosingCapture() =>
      _currentGame.record.moves.length >= _movesPerUndo,
    ComputerThinking() || GameEnded() => false,
  };

  Future<void> _onEvent(GameEvent event, Emitter<GameViewState> emit) async {
    switch (event) {
      case GameStarted(:final opponent, :final config):
        await _start(opponent, config, emit);
      case GameRestarted():
        await _start(_currentGame.opponent, _currentGame.record.config, emit);
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
    // Whatever the event led to, the computer plays when it is its turn.
    await _letComputerPlay(emit);
  }

  Future<void> _start(
    Opponent opponent,
    GameConfig config,
    Emitter<GameViewState> emit,
  ) async {
    _undone.clear();
    _show(await _startNewGame(config: config, opponent: opponent), emit);
  }

  Future<void> _resume(Emitter<GameViewState> emit) async {
    final game = await _resumeGame() ?? await _restart();
    _undone.clear();
    _show(game, emit);
  }

  /// A new game like the one on screen: same config, same opponent.
  Future<CurrentGame> _restart() {
    final game = _currentGame;
    return _startNewGame(config: game.record.config, opponent: game.opponent);
  }

  Future<void> _onSquareTapped(
    Position square,
    Emitter<GameViewState> emit,
  ) async {
    switch (_turnPhase) {
      case AwaitingPlacement():
        await _place(square, emit);
      case final ChoosingCapture phase:
        _pick(phase, square, emit);
      case ComputerThinking() || GameEnded():
        return;
    }
  }

  /// What a tap on [square] does follows from the legal moves there: none
  /// does nothing, one is played at once, and several mean the player
  /// chooses which capture to make (rule R5).
  Future<void> _place(Position square, Emitter<GameViewState> emit) async {
    final moves = [
      for (final move in _cephalopodRules.legalMoves(_currentGame.state))
        if (move.position == square) move,
    ];
    switch (moves) {
      case []:
        return;
      case [final move]:
        await _play(move, emit);
      case _:
        _turnPhase = TurnPhase.choosingCapture(
          target: square,
          options: [for (final move in moves) move.captures],
        );
        _emitScreen(emit);
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
    final dice = _currentGame.state.board.dice;
    _turnPhase = phase.copyWith(
      selected: selected,
      selectedSum: selected.map((picked) => dice[picked]?.pips ?? 0).sum,
      canConfirm: phase.options.any(
        (option) => const SetEquality<Position>().equals(option, selected),
      ),
    );
    _emitScreen(emit);
  }

  Future<void> _confirm(Emitter<GameViewState> emit) async {
    if (_turnPhase case ChoosingCapture(
      :final target,
      :final selected,
      canConfirm: true,
    )) {
      await _play(Move(target, captures: selected), emit);
    }
  }

  void _cancel(Emitter<GameViewState> emit) {
    if (_turnPhase is ChoosingCapture) {
      _turnPhase = const TurnPhase.awaitingPlacement();
      _emitScreen(emit);
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

  /// Takes back the last [_movesPerUndo] moves, when [_canUndo], and
  /// remembers them for redo. A finished game stays finished.
  Future<void> _undo(Emitter<GameViewState> emit) async {
    if (!_canUndo) return;
    var game = _currentGame;
    for (var i = 0; i < _movesPerUndo; i++) {
      _undone.add(game.record.moves.last);
      game = await _undoMove(game);
    }
    _show(game, emit);
  }

  /// Plays again the last [_movesPerUndo] moves taken back, if there are
  /// any.
  Future<void> _redo(Emitter<GameViewState> emit) async {
    if (_undone.isEmpty) return;
    var game = _currentGame;
    for (var i = 0; i < _movesPerUndo && _undone.isNotEmpty; i++) {
      final move = _undone.removeLast();
      if (await _playMove(game, move) case Ok(:final value)) game = value;
    }
    _show(game, emit);
  }

  /// Lets the computer play while the screen shows it thinking. Other
  /// events wait until it has played.
  Future<void> _letComputerPlay(Emitter<GameViewState> emit) async {
    if (_turnPhase is! ComputerThinking) return;
    _show(await _requestAgentMove(_currentGame), emit);
  }

  /// Keeps [game], the result of a use case, for the next move, and shows
  /// it.
  void _show(CurrentGame game, Emitter<GameViewState> emit) {
    _currentGame = game;
    _turnPhase = _phaseOf(game);
    _emitScreen(emit);
  }

  /// Emits what the screen shows of the game and the turn phase.
  void _emitScreen(Emitter<GameViewState> emit) {
    final game = _currentGame;
    emit(
      GameViewState(
        game: game.state,
        phase: _turnPhase,
        lastMove: game.record.moves.lastOrNull,
        canUndo: _canUndo,
        canRedo: _undone.isNotEmpty,
        opponent: game.opponent,
      ),
    );
  }

  TurnPhase _phaseOf(CurrentGame game) {
    if (_requestAgentMove.isComputerTurn(game)) {
      return const TurnPhase.computerThinking();
    }
    return switch (game.state.status) {
      final Finished result => TurnPhase.gameEnded(result),
      InProgress() => const TurnPhase.awaitingPlacement(),
    };
  }
}
