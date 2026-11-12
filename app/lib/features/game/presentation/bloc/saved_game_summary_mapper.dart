import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/side_ui_mapper.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Describes a [CurrentGame] as the [SavedGameSummary] that Home shows: its
/// board, each side's name, dice and turn, and the computer's level.
final class SavedGameSummaryMapper {
  const SavedGameSummaryMapper({this._sideUiMapper = const SideUiMapper()});

  final SideUiMapper _sideUiMapper;

  SavedGameSummary map(CurrentGame game) {
    final CurrentGame(:state, :opponent) = game;
    final toMove = switch (state.status) {
      InProgress(:final toMove) => toMove,
      Finished() => null,
    };

    SideSummary sideOf(Player player) => (
      side: _sideUiMapper.map(player, opponent),
      dice: state.board.dice.values.where((die) => die.owner == player).length,
      toMove: player == toMove,
    );

    return SavedGameSummary(
      board: state.board,
      black: sideOf(Player.black),
      white: sideOf(Player.white),
      computerLevel: switch (opponent) {
        FriendOpponent() => null,
        ComputerOpponent(:final difficulty) => _levelOf(difficulty),
      },
    );
  }

  ComputerLevel _levelOf(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => ComputerLevel.easy,
    Difficulty.medium => ComputerLevel.medium,
    Difficulty.hard => ComputerLevel.hard,
  };
}
