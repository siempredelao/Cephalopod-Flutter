import 'package:cephalopod/features/game/presentation/bloc/hint_state.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'turn_phase.freezed.dart';

/// What the game screen is waiting for. The phase decides which taps do
/// something and which controls the screen shows.
///
/// A freezed union: each factory is a subclass, and a `switch` over the
/// phases must handle all of them (docs/adr/0011).
@freezed
sealed class TurnPhase with _$TurnPhase {
  /// The player to move picks a vacant square. Meanwhile, they may ask for
  /// a [hint]: there is none at first, then it is searched for, then found.
  /// No other phase has one, so a hint cannot outlive the placement it was
  /// for.
  const factory TurnPhase.awaitingPlacement({
    @Default(HintState.none()) HintState hint,
  }) = AwaitingPlacement;

  /// A die placed on [target] can capture in more than one way, so the player
  /// picks the dice to capture from [options].
  ///
  /// [selectedSum] and [canConfirm] describe [selected] in the form the
  /// screen shows it; the bloc keeps them up to date.
  const factory TurnPhase.choosingCapture({
    required Position target,
    required List<Set<Position>> options,
    @Default(<Position>{}) Set<Position> selected,
    @Default(0) int selectedSum,
    @Default(false) bool canConfirm,
  }) = ChoosingCapture;

  /// The computer is choosing its move. The board takes no taps meanwhile.
  const factory TurnPhase.computerThinking() = ComputerThinking;

  /// The board is full and [result] says who won.
  const factory TurnPhase.gameEnded(Finished result) = GameEnded;
}
