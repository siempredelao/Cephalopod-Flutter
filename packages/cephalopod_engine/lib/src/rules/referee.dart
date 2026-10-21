import 'package:cephalopod_engine/src/model/board.dart';
import 'package:cephalopod_engine/src/model/game_status.dart';
import 'package:cephalopod_engine/src/model/player.dart';

/// Decides whether a game is over and who won (rule R8).
final class Referee {
  /// The status of a game with [board] when [nextToMove] would play next.
  ///
  /// The game goes on until every square holds a die. Then the player whose
  /// dice fill the majority of the squares wins; with an odd number of
  /// squares there is always a majority.
  GameStatus statusOf(Board board, Player nextToMove) {
    if (board.dice.length < board.size * board.size) {
      return InProgress(nextToMove);
    }
    final blackDice = board.dice.values
        .where((die) => die.owner == Player.black)
        .length;
    final whiteDice = board.dice.length - blackDice;
    return Finished(
      winner: blackDice > whiteDice ? Player.black : Player.white,
      blackDice: blackDice,
      whiteDice: whiteDice,
    );
  }
}
