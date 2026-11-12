import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_game_summary.freezed.dart';

/// How strongly the computer plays, as the screens that are not the game
/// itself name it.
enum ComputerLevel { easy, medium, hard }

/// One side of a saved game: who it is on screen (`side`), how many dice it
/// has on the board (`dice`), and whether it is to move (`toMove`).
///
/// A Dart record, so it is plain data with value equality.
typedef SideSummary = ({SideUi side, int dice, bool toMove});

/// A saved game described for the screens that show it without being the
/// game: the [board] it stands on, each side of it, and, when the person
/// plays the computer, the computer's level.
///
/// Home offers it to continue, and the feature that owns the game builds it,
/// so the two need not know about each other (docs/adr/0013).
@freezed
abstract class SavedGameSummary with _$SavedGameSummary {
  const factory SavedGameSummary({
    required Board board,
    required SideSummary black,
    required SideSummary white,

    /// How strongly the computer plays; `null` against a friend.
    ComputerLevel? computerLevel,
  }) = _SavedGameSummary;
}
