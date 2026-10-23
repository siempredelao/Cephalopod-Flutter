import 'package:cephalopod_engine/src/models/position.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// One turn: a die placed on [position], removing the dice on [captures].
///
/// The value of the new die is not part of the move: the rules derive it
/// from [captures] (rules R6 and R7).
@immutable
final class Move {
  /// Places a die on [position] and captures the dice on [captures]. Leave
  /// [captures] empty for a non-capturing placement.
  Move(this.position, {Set<Position> captures = const {}})
    : captures = Set.unmodifiable(captures);

  /// The square that receives the new die.
  final Position position;

  /// The adjacent squares whose dice are removed; empty for no capture.
  final Set<Position> captures;

  @override
  bool operator ==(Object other) =>
      other is Move &&
      other.position == position &&
      const SetEquality<Position>().equals(other.captures, captures);

  @override
  int get hashCode => Object.hash(position, Object.hashAllUnordered(captures));

  @override
  String toString() => 'Move($position, captures: $captures)';
}
