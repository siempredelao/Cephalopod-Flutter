import 'package:cephalopod_engine/src/model/player.dart';
import 'package:meta/meta.dart';

/// Whether a game is still being played and, once it is over, who won.
///
/// Only a game in progress has a player to move, so a finished game cannot
/// be asked whose turn it is.
@immutable
sealed class GameStatus {
  const GameStatus();
}

/// The game goes on, and [toMove] places the next die.
final class InProgress extends GameStatus {
  /// A game in progress with [toMove] to play.
  const InProgress(this.toMove);

  /// The player who places the next die.
  final Player toMove;

  @override
  bool operator ==(Object other) =>
      other is InProgress && other.toMove == toMove;

  @override
  int get hashCode => toMove.hashCode;

  @override
  String toString() => 'InProgress(toMove: ${toMove.name})';
}

/// The board is full and the game is over (rule R8).
final class Finished extends GameStatus {
  /// A finished game won by [winner], with [blackDice] black and [whiteDice]
  /// white dice on the board.
  const Finished({
    required this.winner,
    required this.blackDice,
    required this.whiteDice,
  });

  /// The player whose dice occupy the majority of the squares.
  final Player winner;

  /// How many dice Black has on the full board.
  final int blackDice;

  /// How many dice White has on the full board.
  final int whiteDice;

  @override
  bool operator ==(Object other) =>
      other is Finished &&
      other.winner == winner &&
      other.blackDice == blackDice &&
      other.whiteDice == whiteDice;

  @override
  int get hashCode => Object.hash(winner, blackDice, whiteDice);

  @override
  String toString() =>
      'Finished(winner: ${winner.name}, blackDice: $blackDice, '
      'whiteDice: $whiteDice)';
}
