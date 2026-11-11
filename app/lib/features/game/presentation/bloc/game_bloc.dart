import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/use_cases/choose_agent_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/start_new_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/suggest_move.dart';
import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/countdown_timer.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/hint_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/played_move.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// The game screen's view model: turns taps into engine moves and works out
/// what the screen shows. The rules stay in the engine; this class only asks
/// it which moves are legal, and plays, undoes and saves them through the
/// use cases. Against the computer, it lets the computer play its turns. On
/// request, it looks for a hint.
///
/// It keeps the game to itself and emits a [GameViewState], which only
/// describes the screen (docs/adr/0015).
class GameBloc extends Bloc<GameEvent, GameViewState> {
  /// Shows a new game under [config] until the opening event replaces it,
  /// or the given [position], which tests use to start mid-game. The board
  /// marks the last move when [highlightLastMove] is on. After every move,
  /// the game runs [moveCountdown], so the player sees what changed before
  /// anything else moves: taps are ignored, and the computer does not
  /// reply, until it ends. By default it has no length.
  ///
  /// A factory, so that it builds the starting game once and hands it to
  /// `GameBloc._`, which both keeps it and maps the first screen from it.
  /// One constructor could not: `super(...)` runs before the body, and sees
  /// only the parameters.
  factory GameBloc({
    required CephalopodRules cephalopodRules,
    required StartNewGame startNewGame,
    required PlayMove playMove,
    required UndoMove undoMove,
    required ResumeGame resumeGame,
    required ChooseAgentMove chooseAgentMove,
    required SuggestMove suggestMove,
    GameViewStateMapper gameViewStateMapper = const GameViewStateMapper(),
    bool highlightLastMove = true,
    CountdownTimer? moveCountdown,
    GameConfig config = GameConfig.standard,
    @visibleForTesting GameState? position,
  }) {
    return GameBloc._(
      cephalopodRules: cephalopodRules,
      startNewGame: startNewGame,
      playMove: playMove,
      undoMove: undoMove,
      resumeGame: resumeGame,
      chooseAgentMove: chooseAgentMove,
      suggestMove: suggestMove,
      gameViewStateMapper: gameViewStateMapper,
      highlightLastMove: highlightLastMove,
      moveCountdown: moveCountdown ?? CountdownTimer(Duration.zero),
      currentGame: (
        record: GameRecord(config: config),
        opponent: const FriendOpponent(),
        state: position ?? cephalopodRules.newGame(config),
      ),
    );
  }

  /// Shows [_currentGame] as it starts: waiting for the first placement,
  /// with nothing to undo or redo.
  GameBloc._({
    required this._cephalopodRules,
    required this._startNewGame,
    required this._playMove,
    required this._undoMove,
    required this._resumeGame,
    required this._chooseAgentMove,
    required this._suggestMove,
    required this._gameViewStateMapper,
    required this._highlightLastMove,
    required this._moveCountdown,
    required this._currentGame,
  }) : super(
         _gameViewStateMapper.map(
           game: _currentGame.state,
           opponent: _currentGame.opponent,
           lastMove: null,
           phase: const TurnPhase.awaitingPlacement(),
           highlightLastMove: _highlightLastMove,
           canUndo: false,
           canRedo: false,
         ),
       ) {
    // Events wait for storage, so they run one at a time, in order: each
    // sees the game the one before it left.
    on<GameEvent>(_onEvent, transformer: _inOrder);
  }

  final CephalopodRules _cephalopodRules;
  final StartNewGame _startNewGame;
  final PlayMove _playMove;
  final UndoMove _undoMove;
  final ResumeGame _resumeGame;
  final ChooseAgentMove _chooseAgentMove;
  final SuggestMove _suggestMove;
  final GameViewStateMapper _gameViewStateMapper;

  /// Whether the board marks the last move, as the player's settings say.
  final bool _highlightLastMove;

  /// Runs after every move, so the player sees it before the next one.
  final CountdownTimer _moveCountdown;

  /// The game on screen, as the use cases take and give it. The bloc keeps
  /// it here; its state only describes the screen.
  CurrentGame _currentGame;

  /// The move just played, by either side, that led to the game on screen.
  /// Anything else that changes the game clears it.
  PlayedMove? _playedMove;

  /// What the screen is waiting for. While a die is to be placed, it also
  /// holds the hint, if one was asked for; any new phase starts without
  /// one, so a hint never outlives the placement it was for.
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

  static Stream<E> _inOrder<E>(Stream<E> events, EventMapper<E> mapper) =>
      events.asyncExpand(mapper);

  /// Whether a turn can be taken back: there is one, and neither the
  /// computer is thinking nor the game is over.
  bool get _canUndo => switch (_turnPhase) {
    AwaitingPlacement() ||
    ChoosingCapture() => _currentGame.record.moves.length >= _movesPerUndo,
    ComputerThinking() || GameEnded() => false,
  };

  Future<void> _onEvent(GameEvent event, Emitter<GameViewState> emit) async {
    // A move is not started while the last one is still being watched.
    if (_moveCountdown.isActive && event is SquareTapped) return;
    switch (event) {
      case GameStarted(:final opponent, :final config):
        await _start(opponent, config, emit);
      case GameRestarted():
        await _start(_currentGame.opponent, _currentGame.record.config, emit);
      case GameResumed():
        await _resume(emit);
      case SquareTapped(:final row, :final col):
        await _onSquareTapped(Position(row, col), emit);
      case CaptureConfirmed():
        await _confirm(emit);
      case CaptureCancelled():
        _cancel(emit);
      case UndoRequested():
        await _undo(emit);
      case RedoRequested():
        await _redo(emit);
      case HintRequested():
        await _lookForHint(emit);
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
    final before = _currentGame;
    if (await _playMove(before, move) case Ok(:final value)) {
      _undone.clear();
      _show(
        value,
        emit,
        playedMove: (
          move: move,
          byComputer: false,
          captured: _capturedBy(move, before.state),
        ),
      );
    }
  }

  /// Takes back the last [_movesPerUndo] moves, when [_canUndo], and
  /// remembers them for redo. A finished game stays finished.
  Future<void> _undo(Emitter<GameViewState> emit) async {
    if (!_canUndo) return;
    final game = _currentGame;
    // Most recent last: the latest move goes in first, so redo, which takes
    // from the end, plays the earlier one first.
    _undone.addAll(game.record.moves.reversed.take(_movesPerUndo));
    _show(await _undoMove(game, count: _movesPerUndo), emit);
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

  /// Looks for a hint for the side to move while the screen says so, then
  /// shows it. Only while a die can be placed and no hint is asked for yet:
  /// there is nothing to suggest while the computer thinks, a capture is
  /// being chosen, or after the game ends. Other events wait until it is
  /// found.
  Future<void> _lookForHint(Emitter<GameViewState> emit) async {
    final canLook = switch (_turnPhase) {
      AwaitingPlacement(hint: NoHint()) => true,
      AwaitingPlacement() ||
      ChoosingCapture() ||
      ComputerThinking() ||
      GameEnded() => false,
    };
    if (!canLook) return;
    // The last move is still being watched; the hint comes after it.
    await _moveCountdown.done;
    _turnPhase = const TurnPhase.awaitingPlacement(
      hint: HintState.searching(),
    );
    _emitScreen(emit);
    final move = await _suggestMove(_currentGame);
    // The screen may have closed while the agent looked.
    if (isClosed) return;
    _turnPhase = TurnPhase.awaitingPlacement(hint: HintState.found(move));
    _emitScreen(emit);
  }

  /// The dice [move] captures in [before], the game it is played in, and
  /// where they were. They are gone from the board once it is played.
  static Map<Position, Die> _capturedBy(Move move, GameState before) => {
    for (final square in move.captures) square: before.board.dice[square]!,
  };

  /// Lets the computer play while the screen shows it thinking. Other
  /// events wait until it has played.
  ///
  /// Throws a [StateError] when the agent chooses an illegal move: that is a
  /// bug in the agent, not an outcome to handle (docs/adr/0004).
  Future<void> _letComputerPlay(Emitter<GameViewState> emit) async {
    if (_turnPhase is! ComputerThinking) return;
    final game = _currentGame;
    final move = await _chooseAgentMove(game);
    // Wait for the person's move to be seen, if it still has not been.
    await _moveCountdown.done;
    // The screen may have closed while the computer thought, and a new game
    // may be saved since. Playing the move now would save this old game
    // over it, so the move is dropped.
    if (isClosed) return;
    switch (await _playMove(game, move)) {
      case Ok(:final value):
        _show(
          value,
          emit,
          playedMove: (
            move: move,
            byComputer: true,
            captured: _capturedBy(move, game.state),
          ),
        );
      case Err(:final error):
        throw StateError('The agent chose $move: $error');
    }
  }

  /// Keeps [game], the result of a use case, for the next move, and shows
  /// it. [playedMove] is the move just played that led to it, the
  /// computer's or the person's; there is none after a turn taken back or
  /// played again, or another game.
  void _show(
    CurrentGame game,
    Emitter<GameViewState> emit, {
    PlayedMove? playedMove,
  }) {
    _currentGame = game;
    _playedMove = playedMove;
    _turnPhase = _phaseOf(game);
    if (playedMove != null) {
      _moveCountdown.start();
    } else {
      _moveCountdown.cancel();
    }
    _emitScreen(emit);
  }

  @override
  Future<void> close() {
    _moveCountdown.cancel();
    return super.close();
  }

  /// Emits what the screen shows of the game and the turn phase.
  void _emitScreen(Emitter<GameViewState> emit) {
    final game = _currentGame;
    final screen = _gameViewStateMapper.map(
      game: game.state,
      opponent: game.opponent,
      lastMove: game.record.moves.lastOrNull,
      phase: _turnPhase,
      highlightLastMove: _highlightLastMove,
      canUndo: _canUndo,
      canRedo: _undone.isNotEmpty,
      playedMove: _playedMove,
    );
    emit(screen);
  }

  TurnPhase _phaseOf(CurrentGame game) {
    if (_chooseAgentMove.isComputerTurn(game)) {
      return const TurnPhase.computerThinking();
    }
    return switch (game.state.status) {
      final Finished result => TurnPhase.gameEnded(result),
      InProgress() => const TurnPhase.awaitingPlacement(),
    };
  }
}
