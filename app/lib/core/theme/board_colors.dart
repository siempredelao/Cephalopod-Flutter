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
    required this.squareEdge,
    required this.blackDie,
    required this.blackPips,
    required this.whiteDie,
    required this.whitePips,
    required this.lastMove,
    required this.captureTarget,
    required this.captureOption,
    required this.captureSelected,
  });

  /// The palette of the app icon and store art (see art/README.md): a dark
  /// teal board, mint highlights and coral for the dice picked to capture.
  static const BoardColors light = BoardColors(
    board: Color(0xFF03201C),
    square: Color(0xFF0C443C),
    squareEdge: Color(0x802A8073),
    blackDie: Color(0xFF1A1A1A),
    blackPips: Color(0xFFF5F5F5),
    whiteDie: Color(0xFFF5F5F5),
    whitePips: Color(0xFF3A1208),
    lastMove: Color(0xFF5EEAD4),
    captureTarget: Color(0xFFFFB199),
    captureOption: Color(0xFF5EEAD4),
    captureSelected: Color(0xFFFF7A5C),
  );

  /// The board is already dark, so the dark theme keeps the same colours.
  static const BoardColors dark = light;

  /// Behind the squares, showing as the lines between them.
  final Color board;

  /// A square, empty or under a die.
  final Color square;

  /// The thin outline of a square that is not marked.
  final Color squareEdge;

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
    Color? squareEdge,
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
      squareEdge: squareEdge ?? this.squareEdge,
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

  /// Blends towards [other] when the theme animates.
  @override
  BoardColors lerp(BoardColors? other, double t) {
    if (other == null) return this;
    return BoardColors(
      board: Color.lerp(board, other.board, t)!,
      square: Color.lerp(square, other.square, t)!,
      squareEdge: Color.lerp(squareEdge, other.squareEdge, t)!,
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
