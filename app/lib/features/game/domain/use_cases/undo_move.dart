import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Takes back the last moves and saves the game without them.
final class UndoMove {
  UndoMove({required this._cephalopodRules, required this._gameRepository});

  final CephalopodRules _cephalopodRules;
  final GameRepository _gameRepository;

  /// [game] without its last [count] moves, or all of them when fewer were
  /// played, already saved; [game] itself when there is nothing to take
  /// back.
  ///
  /// However many moves go, the game is replayed and saved once. The
  /// position comes from replaying the moves that are left (docs/adr/0003),
  /// so undo and resume share one code path.
  ///
  /// Throws a [RangeError] when [count] is negative.
  Future<CurrentGame> call(CurrentGame game, {int count = 1}) async {
    RangeError.checkNotNegative(count, 'count');
    final moves = game.record.moves;
    final kept = (moves.length - count).clamp(0, moves.length);
    if (kept == moves.length) return game;
    final record = GameRecord(
      config: game.record.config,
      moves: moves.sublist(0, kept),
    );
    final state = switch (_cephalopodRules.replay(record)) {
      Ok(:final value) => value,
      // Each move was legal when it was played, so the moves before the ones
      // taken back replay. Failing here means the record was built some
      // other way.
      Err(:final error) => throw StateError('Cannot replay $record: $error'),
    };
    final opponent = game.opponent;
    await _gameRepository.save((record: record, opponent: opponent));
    return (record: record, opponent: opponent, state: state);
  }
}
