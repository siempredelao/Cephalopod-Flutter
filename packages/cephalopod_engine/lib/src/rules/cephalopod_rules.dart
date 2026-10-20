import 'package:cephalopod_engine/src/model/board.dart';
import 'package:cephalopod_engine/src/model/die.dart';
import 'package:cephalopod_engine/src/model/game_config.dart';
import 'package:cephalopod_engine/src/model/game_state.dart';
import 'package:cephalopod_engine/src/model/game_status.dart';
import 'package:cephalopod_engine/src/model/move.dart';
import 'package:cephalopod_engine/src/model/player.dart';
import 'package:cephalopod_engine/src/model/position.dart';
import 'package:cephalopod_engine/src/result.dart';
import 'package:cephalopod_engine/src/rules/board_geometry.dart';
import 'package:cephalopod_engine/src/rules/capture_finder.dart';
import 'package:cephalopod_engine/src/rules/illegal_move.dart';
import 'package:cephalopod_engine/src/rules/referee.dart';
import 'package:collection/collection.dart';

/// The rules of Cephalopod: how a game starts, which moves are legal and
/// what a move does.
///
/// Pure: the same state and move always give the same result, and nothing
/// outside the returned value changes.
final class CephalopodRules {
  final BoardGeometry _geometry = BoardGeometry();
  final CaptureFinder _captureFinder = CaptureFinder();
  final Referee _referee = Referee();

  static const SetEquality<Position> _sameSquares = SetEquality<Position>();

  /// The value a non-capturing die shows (rule R7).
  static const int _nonCapturingPips = 1;

  /// The highest value a die can show.
  static const int _maxPips = 6;

  /// A new game under [config]: an empty board, [GameConfig.firstPlayer] to
  /// move.
  ///
  /// Throws an [ArgumentError] when [config] breaks the rules: an even board
  /// size (a draw would become possible), a capture sum above 6 (no die could
  /// show it) or captures of fewer than 2 dice.
  GameState newGame([GameConfig config = GameConfig.standard]) {
    if (config.boardSize < 1 || config.boardSize.isEven) {
      throw ArgumentError.value(config.boardSize, 'boardSize', 'must be odd');
    }
    if (config.maxCaptureSum > _maxPips) {
      throw ArgumentError.value(
        config.maxCaptureSum,
        'maxCaptureSum',
        'must be at most $_maxPips',
      );
    }
    if (config.minCaptureDice < 2) {
      throw ArgumentError.value(
        config.minCaptureDice,
        'minCaptureDice',
        'must be at least 2',
      );
    }
    return GameState(
      board: Board(size: config.boardSize),
      status: InProgress(config.firstPlayer),
      config: config,
    );
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
  /// illegal. Checks run in a fixed order, and the first failure is returned.
  Result<GameState, IllegalMove> apply(GameState state, Move move) {
    final status = state.status;
    if (status is! InProgress) return Err(GameOver());

    final board = state.board;
    final target = move.position;
    final captures = move.captures;
    if (!_geometry.contains(target, board.size)) {
      return Err(OutsideBoard(target));
    }
    if (board.dice.containsKey(target)) return Err(SquareOccupied(target));

    final options = _captureFinder.optionsAt(board, target, state.config);
    if (options.isNotEmpty && captures.isEmpty) {
      return Err(CaptureRequired(options));
    }
    final isAnOption = options.any(
      (option) => _sameSquares.equals(option, captures),
    );
    if (captures.isNotEmpty && !isAnOption) {
      return Err(InvalidCapture(captures));
    }

    // R6: a capturing die shows the sum it captured. R7: otherwise a 1.
    final pips = captures.isEmpty
        ? _nonCapturingPips
        : _captureFinder.pipSum(board, captures);
    final next = Board(
      size: board.size,
      dice: {
        for (final MapEntry(:key, :value) in board.dice.entries)
          if (!captures.contains(key)) key: value,
        target: Die(owner: status.toMove, pips: pips),
      },
    );
    return Ok(
      GameState(
        board: next,
        status: _referee.statusOf(next, opponentOf(status.toMove)),
        config: state.config,
      ),
    );
  }

  Iterable<Move> _movesAt(GameState state, Position square) {
    final options = _captureFinder.optionsAt(state.board, square, state.config);
    if (options.isEmpty) return [Move(square)];
    return options.map((captures) => Move(square, captures: captures));
  }
}
