import 'package:cephalopod_engine/src/model/game_config.dart';
import 'package:cephalopod_engine/src/model/move.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// A game as it is saved: the [config] it is played under and the [moves]
/// played so far, first to last.
///
/// It holds no board: `CephalopodRules.replay` rebuilds any position by
/// playing the moves, which also checks that a saved game is valid
/// (docs/adr/0003).
@immutable
final class GameRecord {
  /// A game under [config] with [moves] played; a new standard game by
  /// default.
  GameRecord({this.config = GameConfig.standard, List<Move> moves = const []})
    : moves = List.unmodifiable(moves);

  /// The numbers that define the game.
  final GameConfig config;

  /// The moves played, first to last.
  final List<Move> moves;

  @override
  bool operator ==(Object other) =>
      other is GameRecord &&
      other.config == config &&
      const ListEquality<Move>().equals(other.moves, moves);

  @override
  int get hashCode => Object.hash(config, Object.hashAll(moves));

  @override
  String toString() => 'GameRecord(config: $config, moves: $moves)';
}
