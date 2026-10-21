import 'package:cephalopod_engine/src/model/board.dart';
import 'package:cephalopod_engine/src/model/die.dart';
import 'package:cephalopod_engine/src/model/game_config.dart';
import 'package:cephalopod_engine/src/model/game_record.dart';
import 'package:cephalopod_engine/src/model/game_state.dart';
import 'package:cephalopod_engine/src/model/game_status.dart';
import 'package:cephalopod_engine/src/model/move.dart';
import 'package:cephalopod_engine/src/model/player.dart';
import 'package:cephalopod_engine/src/model/position.dart';
import 'package:cephalopod_engine/src/result.dart';
import 'package:cephalopod_engine/src/rules/board_geometry.dart';
import 'package:cephalopod_engine/src/rules/capture_finder.dart';
import 'package:cephalopod_engine/src/rules/illegal_move.dart';
import 'package:cephalopod_engine/src/rules/move_validator.dart';
import 'package:cephalopod_engine/src/rules/referee.dart';
import 'package:cephalopod_engine/src/rules/replay_failure.dart';

/// The rules of Cephalopod: how a game starts, which moves are legal and
/// what a move does.
///
/// Pure: the same state and move always give the same result, and nothing
/// outside the returned value changes.
final class CephalopodRules {
  /// The rules, built from their parts. This is the engine's composition
  /// root: the only place that creates its services and wires them together.
  ///
  /// Any part can be passed in; the rest are created here, sharing one
  /// [BoardGeometry] and one [CaptureFinder].
  factory CephalopodRules({
    BoardGeometry? geometry,
    CaptureFinder? captureFinder,
    MoveValidator? validator,
    Referee? referee,
  }) {
    final sharedGeometry = geometry ?? BoardGeometry();
    final sharedFinder =
        captureFinder ?? CaptureFinder(geometry: sharedGeometry);
    return CephalopodRules._(
      geometry: sharedGeometry,
      captureFinder: sharedFinder,
      validator:
          validator ??
          MoveValidator(geometry: sharedGeometry, captureFinder: sharedFinder),
      referee: referee ?? Referee(),
    );
  }

  CephalopodRules._({
    required this._geometry,
    required this._captureFinder,
    required this._validator,
    required this._referee,
  });

  final BoardGeometry _geometry;
  final CaptureFinder _captureFinder;
  final MoveValidator _validator;
  final Referee _referee;

  /// The value a non-capturing die shows (rule R7).
  static const int _nonCapturingPips = 1;

  /// A new game under [config]: an empty board, [GameConfig.firstPlayer] to
  /// move.
  ///
  /// Throws an [ArgumentError] when [config] breaks the rules: an even board
  /// size, which would allow a draw; captures of fewer than 2 or more than 4
  /// dice; or a capture sum outside 2 to 6, which no die could show.
  GameState newGame([GameConfig config = GameConfig.standard]) {
    if (_ruleBrokenBy(config) case final error?) throw error;
    return GameState(
      board: Board(size: config.boardSize),
      status: InProgress(config.firstPlayer),
      config: config,
    );
  }

  /// The rule [config] breaks, as the error [newGame] throws, or `null` when
  /// it keeps them all.
  ArgumentError? _ruleBrokenBy(GameConfig config) {
    final GameConfig(:boardSize, :minCaptureDice, :maxCaptureSum) = config;
    if (boardSize < 1 || boardSize.isEven) {
      return ArgumentError.value(boardSize, 'boardSize', 'must be odd');
    }
    // A capture takes 2 to 4 dice (a square has at most 4 neighbours), and
    // the capturing die shows their sum, so that sum lies between 2 and 6.
    if (minCaptureDice < 2 || minCaptureDice > 4) {
      return RangeError.range(minCaptureDice, 2, 4, 'minCaptureDice');
    }
    if (maxCaptureSum < 2 || maxCaptureSum > 6) {
      return RangeError.range(maxCaptureSum, 2, 6, 'maxCaptureSum');
    }
    return null;
  }

  /// The position [record] reaches: its moves played in order from a new
  /// game under its config.
  ///
  /// A record that cannot be replayed, such as a corrupted save, gives the
  /// reason instead: a config that breaks the rules, or the first move that
  /// is illegal where it is played.
  Result<GameState, ReplayFailure> replay(GameRecord record) {
    if (_ruleBrokenBy(record.config) case final error?) {
      return Err(InvalidConfig(error));
    }
    var state = newGame(record.config);
    for (final (index, move) in record.moves.indexed) {
      switch (apply(state, move)) {
        case Ok(:final value):
          state = value;
        case Err(:final error):
          return Err(IllegalMoveAt(index, error));
      }
    }
    return Ok(state);
  }

  /// The player who moves after [player]: turns alternate (rule R1).
  Player opponentOf(Player player) => switch (player) {
    Player.black => Player.white,
    Player.white => Player.black,
  };

  /// Every legal move in [state], ordered by target square (row-major).
  ///
  /// Empty once the game is over. Otherwise never empty, because every
  /// vacant square accepts a die (rule R2): a non-capturing die where no
  /// capture is possible, otherwise one move per capture option (rule R5).
  List<Move> legalMoves(GameState state) {
    if (state.status is! InProgress) return const [];
    final board = state.board;
    return [
      for (final square in _geometry.squares(board.size))
        if (!board.dice.containsKey(square)) ..._movesAt(state, square),
    ];
  }

  /// Plays [move] in [state]: the next state, or the reason the move is
  /// illegal. A finished game refuses every move (rule R8); otherwise the
  /// [MoveValidator] reports the first rule the move breaks.
  Result<GameState, IllegalMove> apply(GameState state, Move move) {
    final status = state.status;
    if (status is! InProgress) return Err(GameOver());
    if (_validator.violationOf(state, move) case final violation?) {
      return Err(violation);
    }
    return Ok(_play(state, move, status.toMove));
  }

  /// Plays a validated [move] by [player]: the captured dice leave the board
  /// and the new die shows their sum (rule R6), or 1 without a capture (R7).
  GameState _play(GameState state, Move move, Player player) {
    final GameState(:board, :config) = state;
    final captures = move.captures;
    final pips = captures.isEmpty
        ? _nonCapturingPips
        : _captureFinder.pipSum(board, captures);
    final next = Board(
      size: board.size,
      dice: {
        for (final MapEntry(:key, :value) in board.dice.entries)
          if (!captures.contains(key)) key: value,
        move.position: Die(owner: player, pips: pips),
      },
    );
    return GameState(
      board: next,
      status: _referee.statusOf(next, opponentOf(player)),
      config: config,
    );
  }

  Iterable<Move> _movesAt(GameState state, Position square) {
    final options = _captureFinder.optionsAt(state.board, square, state.config);
    if (options.isEmpty) return [Move(square)];
    return options.map((captures) => Move(square, captures: captures));
  }
}
