import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Puts an [Opponent] into the game route's query parameters, and takes it
/// back out, so a link can open a game against it.
///
/// A friend needs no parameters, so `/game` is a game between two people.
/// The computer is `?computer=white&difficulty=hard`: the colour it plays,
/// and how strongly.
final class OpponentQueryCodec {
  const OpponentQueryCodec();

  Map<String, String> encode(Opponent opponent) {
    return switch (opponent) {
      FriendOpponent() => const {},
      ComputerOpponent(:final difficulty, :final player) => {
        'computer': player.name,
        'difficulty': difficulty.name,
      },
    };
  }

  /// The opponent in [parameters]; a friend when they name no computer this
  /// version knows.
  Opponent decode(Map<String, String> parameters) {
    final player = Player.values.asNameMap()[parameters['computer']];
    final difficulty = Difficulty.values.asNameMap()[parameters['difficulty']];
    if (player == null || difficulty == null) return const FriendOpponent();
    return ComputerOpponent(difficulty: difficulty, player: player);
  }
}
