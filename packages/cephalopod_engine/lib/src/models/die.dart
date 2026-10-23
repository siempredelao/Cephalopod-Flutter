import 'package:cephalopod_engine/src/models/player.dart';
import 'package:meta/meta.dart';

/// A die on the board: its [owner] and the number of [pips] on top.
@immutable
final class Die {
  /// A die of [owner]'s colour showing [pips], from 1 to 6.
  const Die({required this.owner, required this.pips});

  /// The player whose colour this die is.
  final Player owner;

  /// The number of pips on the top face.
  final int pips;

  @override
  bool operator ==(Object other) =>
      other is Die && other.owner == owner && other.pips == pips;

  @override
  int get hashCode => Object.hash(owner, pips);

  /// The short form used in board diagrams: `b3` is a black die showing 3.
  @override
  String toString() => '${owner.name[0]}$pips';
}
