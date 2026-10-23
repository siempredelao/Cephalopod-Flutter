import 'package:cephalopod_engine/src/models/die.dart';
import 'package:cephalopod_engine/src/models/position.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// The dice on a square board of [size] × [size] squares. A square missing
/// from [dice] is vacant.
@immutable
final class Board {
  /// A board of [size] × [size] squares holding [dice]; empty by default.
  Board({required this.size, Map<Position, Die> dice = const {}})
    : dice = Map.unmodifiable(dice);

  /// The number of squares along each side.
  final int size;

  /// The die on each occupied square.
  final Map<Position, Die> dice;

  @override
  bool operator ==(Object other) =>
      other is Board &&
      other.size == size &&
      const MapEquality<Position, Die>().equals(other.dice, dice);

  @override
  int get hashCode => Object.hash(
    size,
    Object.hashAllUnordered([
      for (final MapEntry(:key, :value) in dice.entries)
        Object.hash(key, value),
    ]),
  );

  @override
  String toString() => 'Board(size: $size, dice: $dice)';
}
