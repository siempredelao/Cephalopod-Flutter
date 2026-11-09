import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/models/difficulty_ui.dart';
import 'package:cephalopod/features/game/presentation/models/new_game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/opponent_ui.dart';
import 'package:cephalopod/features/game/presentation/models/person_moves_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns the opponent chosen in the new-game dialog into the
/// [NewGameViewState] it draws, and the dialog's choices back into the
/// computer's settings.
///
/// Both ways live here, so a difficulty added to one side is added to the
/// other in the same file.
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

  /// The difficulty chosen as [difficulty] in the dialog: the way back from
  /// [map].
  Difficulty difficultyOf(DifficultyUi difficulty) => switch (difficulty) {
    DifficultyUi.easy => Difficulty.easy,
    DifficultyUi.medium => Difficulty.medium,
    DifficultyUi.hard => Difficulty.hard,
  };

  /// The colour the computer plays for the person to move as [personMoves]
  /// says: Black moves first, so the person moves first against White. The
  /// way back from [map].
  Player computerPlayerOf(PersonMovesUi personMoves) => switch (personMoves) {
    PersonMovesUi.first => Player.white,
    PersonMovesUi.second => Player.black,
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
