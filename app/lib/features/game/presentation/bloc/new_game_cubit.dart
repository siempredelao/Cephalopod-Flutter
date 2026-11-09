import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/opponent_query_codec.dart';
import 'package:cephalopod/features/game/presentation/models/difficulty_ui.dart';
import 'package:cephalopod/features/game/presentation/models/new_game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/person_moves_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// The computer the new-game dialog offers first: Medium, with the person
/// moving first.
const ComputerOpponent _firstOffer = ComputerOpponent(
  difficulty: Difficulty.medium,
  player: Player.white,
);

/// The new-game dialog's view model. It keeps what the person has chosen so
/// far and emits it as a [NewGameViewState]. It starts on a friend.
///
/// While a friend is chosen, the dialog hides the computer's choices, but
/// the cubit keeps them: choosing the computer again shows them as they
/// were.
class NewGameCubit extends Cubit<NewGameViewState> {
  NewGameCubit({
    this._newGameViewStateMapper = const NewGameViewStateMapper(),
    this._opponentQueryCodec = const OpponentQueryCodec(),
  }) : super(_newGameViewStateMapper.map(const FriendOpponent()));

  final NewGameViewStateMapper _newGameViewStateMapper;
  final OpponentQueryCodec _opponentQueryCodec;

  bool _againstComputer = false;

  /// The computer to play, if the person chooses it.
  ComputerOpponent _computer = _firstOffer;

  /// The game route's query parameters for the opponent chosen, so the
  /// dialog can open the game without knowing who that is.
  Map<String, String> get gameQueryParameters {
    return _opponentQueryCodec.encode(_opponent);
  }

  Opponent get _opponent {
    return _againstComputer ? _computer : const FriendOpponent();
  }

  void chooseFriend() {
    _againstComputer = false;
    _emitChoices();
  }

  void chooseComputer() {
    _againstComputer = true;
    _emitChoices();
  }

  void chooseDifficulty(DifficultyUi difficulty) {
    _computer = ComputerOpponent(
      difficulty: _newGameViewStateMapper.difficultyOf(difficulty),
      player: _computer.player,
    );
    _emitChoices();
  }

  void choosePersonMoves(PersonMovesUi personMoves) {
    _computer = ComputerOpponent(
      difficulty: _computer.difficulty,
      player: _newGameViewStateMapper.computerPlayerOf(personMoves),
    );
    _emitChoices();
  }

  void _emitChoices() => emit(_newGameViewStateMapper.map(_opponent));
}
