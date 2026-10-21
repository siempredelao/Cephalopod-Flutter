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
  /// The player to move picks a vacant square.
  const factory TurnPhase.awaitingPlacement() = AwaitingPlacement;

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

  /// The board is full and [result] says who won.
  const factory TurnPhase.gameEnded(Finished result) = GameEnded;
}
