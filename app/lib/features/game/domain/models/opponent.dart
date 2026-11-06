import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:meta/meta.dart';

/// Who plays the other side of the board.
///
/// Sealed, so a `switch` over it must handle every kind of opponent, and a
/// new kind, such as an online player, shows where it needs handling.
///
/// Plain data with value equality, written by hand like the engine's models
/// (docs/adr/0008, docs/adr/0009).
@immutable
sealed class Opponent {
  const Opponent();
}

/// Another person, taking turns on the same device.
final class FriendOpponent extends Opponent {
  const FriendOpponent();

  @override
  bool operator ==(Object other) => other is FriendOpponent;

  @override
  int get hashCode => (FriendOpponent).hashCode;

  @override
  String toString() => 'FriendOpponent()';
}

/// The computer, playing the dice of [player] at [difficulty]. The person
/// plays the other colour.
final class ComputerOpponent extends Opponent {
  const ComputerOpponent({required this.difficulty, required this.player});

  /// How strongly the computer plays.
  final Difficulty difficulty;

  /// The colour the computer plays.
  final Player player;

  @override
  bool operator ==(Object other) =>
      other is ComputerOpponent &&
      other.difficulty == difficulty &&
      other.player == player;

  @override
  int get hashCode => Object.hash(difficulty, player);

  @override
  String toString() =>
      'ComputerOpponent(difficulty: ${difficulty.name}, '
      'player: ${player.name})';
}
