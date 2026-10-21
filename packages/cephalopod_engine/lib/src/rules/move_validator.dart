import 'package:cephalopod_engine/src/model/game_state.dart';
import 'package:cephalopod_engine/src/model/move.dart';
import 'package:cephalopod_engine/src/model/position.dart';
import 'package:cephalopod_engine/src/rules/board_geometry.dart';
import 'package:cephalopod_engine/src/rules/capture_finder.dart';
import 'package:cephalopod_engine/src/rules/illegal_move.dart';
import 'package:collection/collection.dart';

/// Decides whether a move may be played: one check per rule, run in order.
///
/// The first failed check is reported, so a move on an occupied square is
/// refused as occupied rather than as a bad capture. Adding a rule means one
/// more check in the list.
final class MoveValidator {
  final BoardGeometry _geometry = BoardGeometry();
  final CaptureFinder _captureFinder = CaptureFinder();

  static const SetEquality<Position> _sameSquares = SetEquality<Position>();

  late final List<IllegalMove? Function(GameState, Move)> _checks = [
    _isOnTheBoard,
    _isOnAVacantSquare,
    _capturesWhenItMust,
    _capturesALegalSet,
  ];

  /// Why [move] cannot be played in [state], or `null` when it can.
  ///
  /// Whether the game is already over is checked by `CephalopodRules.apply`,
  /// because that depends on the state, not on the move.
  IllegalMove? violationOf(GameState state, Move move) {
    for (final check in _checks) {
      if (check(state, move) case final violation?) return violation;
    }
    return null;
  }

  IllegalMove? _isOnTheBoard(GameState state, Move move) {
    if (_geometry.contains(move.position, state.board.size)) return null;
    return OutsideBoard(move.position);
  }

  /// Rule R2: a die goes on a vacant square.
  IllegalMove? _isOnAVacantSquare(GameState state, Move move) {
    if (!state.board.dice.containsKey(move.position)) return null;
    return SquareOccupied(move.position);
  }

  /// Rule R5: where a capture is possible, the move must make one.
  IllegalMove? _capturesWhenItMust(GameState state, Move move) {
    final options = _optionsFor(state, move);
    if (options.isEmpty || move.captures.isNotEmpty) return null;
    return CaptureRequired(options);
  }

  /// Rule R4: a capture must be one of the options from the target square.
  IllegalMove? _capturesALegalSet(GameState state, Move move) {
    final captures = move.captures;
    if (captures.isEmpty) return null;
    final options = _optionsFor(state, move);
    if (options.any((option) => _sameSquares.equals(option, captures))) {
      return null;
    }
    return InvalidCapture(captures);
  }

  List<Set<Position>> _optionsFor(GameState state, Move move) =>
      _captureFinder.optionsAt(state.board, move.position, state.config);
}
