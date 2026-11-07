import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/side_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns how the game stands into the [HeadlineUi] above the board: whose
/// turn it is, or who won and by how much, named for who the person faces.
final class HeadlineUiMapper {
  const HeadlineUiMapper({this._sideUiMapper = const SideUiMapper()});

  final SideUiMapper _sideUiMapper;

  HeadlineUi map(GameStatus status, Opponent opponent) {
    return switch (status) {
      InProgress(:final toMove) => _toMoveOf(toMove, opponent),
      Finished(:final winner, :final blackDice, :final whiteDice) => _wonOf(
        winner,
        opponent,
        dice: (black: blackDice, white: whiteDice),
      ),
    };
  }

  /// [player] is to move. Against the computer, its turn is shown as it
  /// thinking, because it plays as soon as its turn comes.
  HeadlineUi _toMoveOf(Player player, Opponent opponent) {
    final sideUi = _sideUiMapper.map(player, opponent);
    return switch (sideUi.role) {
      RoleUi.player => HeadlineUi.playerToMove(sideUi.player),
      RoleUi.you => const HeadlineUi.yourTurn(),
      RoleUi.computer => const HeadlineUi.computerThinking(),
    };
  }

  /// [winner] won; [dice] are the dice each player has on the board.
  HeadlineUi _wonOf(
    Player winner,
    Opponent opponent, {
    required ({int black, int white}) dice,
  }) {
    final (winnerDice, loserDice) = switch (winner) {
      Player.black => (dice.black, dice.white),
      Player.white => (dice.white, dice.black),
    };
    final sideUi = _sideUiMapper.map(winner, opponent);
    return switch (sideUi.role) {
      RoleUi.player => HeadlineUi.playerWon(
        player: sideUi.player,
        winnerDice: winnerDice,
        loserDice: loserDice,
      ),
      RoleUi.you => HeadlineUi.youWon(
        winnerDice: winnerDice,
        loserDice: loserDice,
      ),
      RoleUi.computer => HeadlineUi.computerWon(
        winnerDice: winnerDice,
        loserDice: loserDice,
      ),
    };
  }
}
