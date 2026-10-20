import 'package:cephalopod_engine/src/model/board.dart';
import 'package:cephalopod_engine/src/model/game_config.dart';
import 'package:cephalopod_engine/src/model/game_status.dart';
import 'package:meta/meta.dart';

/// A moment in a game: the [board], the [status] and the [config].
///
/// Plain data: `CephalopodRules` creates every state, which keeps the status
/// consistent with the board.
@immutable
final class GameState {
  /// A state with [board] and [status], played under [config].
  const GameState({
    required this.board,
    required this.status,
    this.config = GameConfig.standard,
  });

  /// The dice on the board.
  final Board board;

  /// Whether the game goes on, and who moves or who won.
  final GameStatus status;

  /// The numbers that define this game.
  final GameConfig config;

  @override
  bool operator ==(Object other) =>
      other is GameState &&
      other.board == board &&
      other.status == status &&
      other.config == config;

  @override
  int get hashCode => Object.hash(board, status, config);

  @override
  String toString() =>
      'GameState(status: $status, config: $config, board: $board)';
}
