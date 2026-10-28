import 'package:cephalopod_engine/src/models/player.dart';
import 'package:meta/meta.dart';

/// The numbers that define a game, in one place. [standard] is the game as
/// published.
///
/// Other values exist for tests, such as a 3 × 3 board for short games; they
/// are not rule variants. `CephalopodRules.newGame` rejects values that break
/// the rules, such as an even board size.
@immutable
final class GameConfig {
  /// A configuration. Every argument defaults to the published rules.
  const GameConfig({
    this.boardSize = 5,
    this.firstPlayer = Player.black,
    this.maxCaptureSum = 6,
    this.minCaptureDice = 2,
  });

  /// The published game: a 5 × 5 board, Black first, captures of 2 or more
  /// dice summing to 6 or less.
  static const GameConfig standard = GameConfig();

  /// The number of squares along each side of the board. Must be odd, so a
  /// full board always has a majority (rule R8).
  final int boardSize;

  /// The player who places the first die. The rule sheet does not say, so
  /// Black is the default.
  final Player firstPlayer;

  /// The highest pip sum a capture can remove (rule R4).
  final int maxCaptureSum;

  /// The fewest dice a capture removes (rule R4).
  final int minCaptureDice;

  @override
  bool operator ==(Object other) =>
      other is GameConfig &&
      other.boardSize == boardSize &&
      other.firstPlayer == firstPlayer &&
      other.maxCaptureSum == maxCaptureSum &&
      other.minCaptureDice == minCaptureDice;

  @override
  int get hashCode =>
      Object.hash(boardSize, firstPlayer, maxCaptureSum, minCaptureDice);

  @override
  String toString() =>
      'GameConfig(boardSize: $boardSize, firstPlayer: ${firstPlayer.name}, '
      'maxCaptureSum: $maxCaptureSum, minCaptureDice: $minCaptureDice)';
}
