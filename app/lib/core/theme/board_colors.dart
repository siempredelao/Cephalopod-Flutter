import 'package:material_ui/material_ui.dart';

/// The colours of the game board and its dice.
///
/// Registered on the app's light and dark themes, so board widgets read them
/// with `Theme.of(context).extension<BoardColors>()` and hard-code none.
@immutable
class BoardColors extends ThemeExtension<BoardColors> {
  const BoardColors({
    required this.board,
    required this.square,
    required this.blackDie,
    required this.blackPips,
    required this.whiteDie,
    required this.whitePips,
    required this.lastMove,
    required this.captureTarget,
    required this.captureOption,
    required this.captureSelected,
  });

  static const BoardColors light = BoardColors(
    board: Color(0xFF6D4C33),
    square: Color(0xFFE9D3AE),
    blackDie: Color(0xFF212121),
    blackPips: Color(0xFFFAFAFA),
    whiteDie: Color(0xFFFAFAFA),
    whitePips: Color(0xFF212121),
    lastMove: Color(0xFFF9A825),
    captureTarget: Color(0xFF6A1B9A),
    captureOption: Color(0xFF00897B),
    captureSelected: Color(0xFFD84315),
  );

  static const BoardColors dark = BoardColors(
    board: Color(0xFF2B1F16),
    square: Color(0xFF6B5139),
    blackDie: Color(0xFF121212),
    blackPips: Color(0xFFE0E0E0),
    whiteDie: Color(0xFFE0E0E0),
    whitePips: Color(0xFF121212),
    lastMove: Color(0xFFFFD54F),
    captureTarget: Color(0xFFCE93D8),
    captureOption: Color(0xFF4DB6AC),
    captureSelected: Color(0xFFFF8A65),
  );

  /// Behind the squares, showing as the lines between them.
  final Color board;

  /// A square, empty or under a die.
  final Color square;

  final Color blackDie;
  final Color blackPips;
  final Color whiteDie;
  final Color whitePips;

  /// The outline of the square where the last die was placed.
  final Color lastMove;

  /// The outline of the square that receives the die while the player
  /// chooses a capture.
  final Color captureTarget;

  /// The outline of a die the player can pick for the capture.
  final Color captureOption;

  /// The outline of a die the player has picked for the capture.
  final Color captureSelected;

  @override
  BoardColors copyWith({
    Color? board,
    Color? square,
    Color? blackDie,
    Color? blackPips,
    Color? whiteDie,
    Color? whitePips,
    Color? lastMove,
    Color? captureTarget,
    Color? captureOption,
    Color? captureSelected,
  }) {
    return BoardColors(
      board: board ?? this.board,
      square: square ?? this.square,
      blackDie: blackDie ?? this.blackDie,
      blackPips: blackPips ?? this.blackPips,
      whiteDie: whiteDie ?? this.whiteDie,
      whitePips: whitePips ?? this.whitePips,
      lastMove: lastMove ?? this.lastMove,
      captureTarget: captureTarget ?? this.captureTarget,
      captureOption: captureOption ?? this.captureOption,
      captureSelected: captureSelected ?? this.captureSelected,
    );
  }

  /// Blends towards [other] when the theme animates, for example between
  /// light and dark.
  @override
  BoardColors lerp(BoardColors? other, double t) {
    if (other == null) return this;
    return BoardColors(
      board: Color.lerp(board, other.board, t)!,
      square: Color.lerp(square, other.square, t)!,
      blackDie: Color.lerp(blackDie, other.blackDie, t)!,
      blackPips: Color.lerp(blackPips, other.blackPips, t)!,
      whiteDie: Color.lerp(whiteDie, other.whiteDie, t)!,
      whitePips: Color.lerp(whitePips, other.whitePips, t)!,
      lastMove: Color.lerp(lastMove, other.lastMove, t)!,
      captureTarget: Color.lerp(captureTarget, other.captureTarget, t)!,
      captureOption: Color.lerp(captureOption, other.captureOption, t)!,
      captureSelected: Color.lerp(captureSelected, other.captureSelected, t)!,
    );
  }
}
