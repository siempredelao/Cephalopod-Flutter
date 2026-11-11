import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/side_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/dice_tally_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Counts each side's dice on the board of a game, for the [DiceTallyUi]
/// the screen shows, named for who the person faces.
final class DiceTallyUiMapper {
  const DiceTallyUiMapper({this._sideUiMapper = const SideUiMapper()});

  final SideUiMapper _sideUiMapper;

  /// The count of each side's dice in [game] against [opponent].
  DiceTallyUi map(GameState game, Opponent opponent) {
    final toMove = switch (game.status) {
      InProgress(:final toMove) => toMove,
      Finished() => null,
    };
    final owners = [for (final die in game.board.dice.values) die.owner];

    SideTallyUi tallyOf(Player player) => SideTallyUi(
      side: _sideUiMapper.map(player, opponent),
      dice: owners.where((owner) => owner == player).length,
      toMove: player == toMove,
    );

    return DiceTallyUi(
      playerOne: tallyOf(Player.black),
      playerTwo: tallyOf(Player.white),
    );
  }
}
