import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/models/difficulty_ui.dart';
import 'package:cephalopod/features/game/presentation/models/new_game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/opponent_ui.dart';
import 'package:cephalopod/features/game/presentation/models/person_moves_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns the opponent chosen in the new-game dialog into the
/// [NewGameViewState] it draws.
final class NewGameViewStateMapper {
  const NewGameViewStateMapper();

  /// The dialog with [opponent] chosen.
  NewGameViewState map(Opponent opponent) {
    final opponentUi = _opponentUiOf(opponent);
    return NewGameViewState(opponent: opponentUi);
  }

  OpponentUi _opponentUiOf(Opponent opponent) => switch (opponent) {
    FriendOpponent() => const OpponentUi.friend(),
    ComputerOpponent(:final difficulty, :final player) => OpponentUi.computer(
      difficulty: _difficultyUiOf(difficulty),
      personMoves: _personMovesUiOf(player),
    ),
  };

  DifficultyUi _difficultyUiOf(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => DifficultyUi.easy,
    Difficulty.medium => DifficultyUi.medium,
    Difficulty.hard => DifficultyUi.hard,
  };

  /// When the person moves, given the [computer]'s colour: Black moves
  /// first, so the computer playing White lets the person move first.
  PersonMovesUi _personMovesUiOf(Player computer) => switch (computer) {
    Player.white => PersonMovesUi.first,
    Player.black => PersonMovesUi.second,
  };
}
