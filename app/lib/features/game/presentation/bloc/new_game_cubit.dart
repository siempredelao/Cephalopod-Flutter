import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_choices.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// The new-game screen's view model: what the person has chosen so far, and
/// the [opponent] that makes. It starts on a friend.
class NewGameCubit extends Cubit<NewGameChoices> {
  NewGameCubit() : super(const NewGameChoices());

  /// Who the person plays against, as chosen.
  Opponent get opponent {
    return state.againstComputer ? state.computer : const FriendOpponent();
  }

  void chooseFriend() => emit(state.copyWith(againstComputer: false));

  void chooseComputer() => emit(state.copyWith(againstComputer: true));

  void chooseDifficulty(Difficulty difficulty) {
    final player = state.computer.player;
    final computer = ComputerOpponent(difficulty: difficulty, player: player);
    emit(state.copyWith(computer: computer));
  }

  /// [player] is the colour the computer plays; the person plays the other.
  void chooseComputerPlayer(Player player) {
    final difficulty = state.computer.difficulty;
    final computer = ComputerOpponent(difficulty: difficulty, player: player);
    emit(state.copyWith(computer: computer));
  }
}
