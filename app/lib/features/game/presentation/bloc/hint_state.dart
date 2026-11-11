import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hint_state.freezed.dart';

/// Where the hint stands while a die is to be placed: none asked for, being
/// searched for, or found. It is part of `TurnPhase.awaitingPlacement`,
/// the only phase in which a hint makes sense.
///
/// A freezed union: each factory is a subclass, and a `switch` over the
/// states must handle all of them (docs/adr/0011).
@freezed
sealed class HintState with _$HintState {
  /// No hint is shown or being looked for.
  const factory HintState.none() = NoHint;

  /// The Hard agent is looking for a move to suggest. The board takes no
  /// taps meanwhile.
  const factory HintState.searching() = HintSearching;

  /// The hint is [move]: the board marks its square and the dice it would
  /// capture, until anything else happens.
  const factory HintState.found(Move move) = HintFound;
}
