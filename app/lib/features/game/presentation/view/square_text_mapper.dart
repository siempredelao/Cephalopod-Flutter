import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_text_mapper.dart';

/// Words what screen readers announce for a square: where it is, counting
/// rows and columns from 1, and what is on it.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class SquareTextMapper {
  const SquareTextMapper({this._playerTextMapper = const PlayerTextMapper()});

  final PlayerTextMapper _playerTextMapper;

  /// "Row 2, column 3, Player 1 die showing 5", "Row 2, column 3, your die
  /// showing 5", or "Row 1, column 3, empty".
  String map(SquareUi square) {
    final where = 'Row ${square.row + 1}, column ${square.col + 1}';
    final die = square.die;
    if (die == null) return '$where, empty';
    return '$where, ${_ownerOf(die.owner)} die showing ${die.pips}';
  }

  /// Whose a die is: "Player 1" between two people, or "your" and "the
  /// computer's" against the computer.
  String _ownerOf(SideUi side) => switch (side.role) {
    RoleUi.player => _playerTextMapper.map(side.player),
    RoleUi.person => 'your',
    RoleUi.computer => "the computer's",
  };
}
