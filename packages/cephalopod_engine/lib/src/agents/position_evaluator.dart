import 'package:cephalopod_engine/src/models/die.dart';
import 'package:cephalopod_engine/src/models/game_config.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/player.dart';

/// Scores a position for one player: higher is better for them, and the
/// opponent's score is the same number negated.
///
/// The game is won by having more dice on the full board (rule R8), so the
/// score counts dice: [dieValue] for each of the player's, minus the same for
/// each of the opponent's. A die no capture can ever remove, such as a 6 in
/// the standard game, is worth [permanentDieValue] instead, because it holds
/// its square to the end. A finished game scores [winScore] for the winner.
///
/// Agents share one evaluator: the Medium agent scores the position after
/// each move, and the Hard agent scores the positions its search reaches.
final class PositionEvaluator {
  /// The score of a won game, and minus that of a lost one. Larger than any
  /// score of a game in progress, so a win always ranks first.
  static const int winScore = 1000;

  /// The value of a die that a capture could still remove.
  static const int dieValue = 1;

  /// The value of a die that no capture can remove. A capture removes at most
  /// 4 dice, so this is worth more than any capture could cost: making one is
  /// always worth it, even by capturing your own dice.
  static const int permanentDieValue = 5;

  /// How good [state] is for [player].
  int score(GameState state, Player player) => switch (state.status) {
    Finished(:final winner) => winner == player ? winScore : -winScore,
    InProgress() => _material(state, player),
  };

  int _material(GameState state, Player player) {
    var total = 0;
    for (final die in state.board.dice.values) {
      final value = _isPermanent(die, state.config)
          ? permanentDieValue
          : dieValue;
      total += die.owner == player ? value : -value;
    }
    return total;
  }

  /// Whether no capture can ever remove [die] (rule R4). A capture takes at
  /// least [GameConfig.minCaptureDice] dice, each showing at least 1, and
  /// their sum must not pass [GameConfig.maxCaptureSum]. So a die is safe
  /// once its pips plus 1 for each other die exceed that sum.
  bool _isPermanent(Die die, GameConfig config) =>
      die.pips + config.minCaptureDice - 1 > config.maxCaptureSum;
}
