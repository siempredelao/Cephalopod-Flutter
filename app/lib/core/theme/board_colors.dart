import 'package:material_ui/material_ui.dart';

/// The colours of the game board and its dice.
///
/// Registered on the app's light and dark themes, so board widgets read them
/// with [BoardColors.of] and hard-code none.
@immutable
class BoardColors extends ThemeExtension<BoardColors> {
  const BoardColors({
    required this.board,
    required this.boardEdge,
    required this.square,
    required this.blackDie,
    required this.blackDieEdge,
    required this.blackPips,
    required this.whiteDie,
    required this.whiteDieEdge,
    required this.whitePips,
    required this.lastMove,
    required this.captureTarget,
    required this.captureOption,
    required this.captureSelected,
    required this.hintTarget,
    required this.hintCapture,
  });

  /// The board colours of the theme around [context].
  ///
  /// Both of the app's themes register them (`AppTheme`), so a theme without
  /// them is a bug, and this fails at once rather than drawing a blank board.
  static BoardColors of(BuildContext context) {
    return Theme.of(context).extension<BoardColors>()!;
  }

  /// The light theme's board: pale sage, with the dice in the same coral and
  /// cream as on the dark board.
  ///
  /// The cream die is almost white, so on a pale square only its edge shows
  /// it: that is a dark brown here, and `DieFace` draws it around the whole
  /// die. The rings are darker than the dark board's glowing ones, to show
  /// on a pale board. Every edge and ring has at least 3 to 1 contrast
  /// against what it sits on (WCAG 1.4.11), which `board_colors_test.dart`
  /// checks.
  static const BoardColors light = BoardColors(
    board: Color(0xFFC9DED8),
    boardEdge: Color(0xFF8FB3AA),
    square: Color(0xFFEAF3F0),
    blackDie: Color(0xFFFF7A5C),
    blackDieEdge: Color(0xFFC24A30),
    blackPips: Color(0xFF3A1208),
    whiteDie: Color(0xFFF6F0E2),
    whiteDieEdge: Color(0xFF7A6A44),
    whitePips: Color(0xFF12312D),
    lastMove: Color(0xFF0B7A6B),
    captureTarget: Color(0xFFC2410C),
    captureOption: Color(0xFF0B7A6B),
    captureSelected: Color(0xFFB42318),
    hintTarget: Color(0xFFA16207),
    hintCapture: Color(0xFF9C6F00),
  );

  /// The dark theme's board, the palette of the repository's social preview
  /// and the app icon (see art/README.md): a dark teal board, coral and
  /// cream dice, and glowing rings around marked squares.
  static const BoardColors dark = BoardColors(
    board: Color(0xFF0C3D37),
    boardEdge: Color(0xFF1D5E55),
    square: Color(0xFF082C28),
    blackDie: Color(0xFFFF7A5C),
    blackDieEdge: Color(0xFFC24A30),
    blackPips: Color(0xFF3A1208),
    whiteDie: Color(0xFFF6F0E2),
    whiteDieEdge: Color(0xFFCBBE9F),
    whitePips: Color(0xFF12312D),
    lastMove: Color(0xFF5EEAD4),
    captureTarget: Color(0xFFFFB199),
    captureOption: Color(0xFF5EEAD4),
    captureSelected: Color(0xFFFF7A5C),
    hintTarget: Color(0xFFFACC15),
    hintCapture: Color(0xFFFDE68A),
  );

  /// The panel the squares sit on, showing in the gaps between them.
  final Color board;

  /// The outline of the panel.
  final Color boardEdge;

  /// An empty square.
  final Color square;

  /// Black's dice: the top face, the darker lower edge and the pips.
  final Color blackDie;
  final Color blackDieEdge;
  final Color blackPips;

  /// White's dice: the top face, the darker lower edge and the pips.
  final Color whiteDie;
  final Color whiteDieEdge;
  final Color whitePips;

  /// The ring around the square where the last die was placed.
  final Color lastMove;

  /// The ring around the square that receives the die while the player
  /// chooses a capture.
  final Color captureTarget;

  /// The ring around a die the player can pick for the capture.
  final Color captureOption;

  /// The ring around a die the player has picked for the capture.
  final Color captureSelected;

  /// The ring around the square a hint suggests: gold, a colour no other
  /// mark uses.
  final Color hintTarget;

  /// The ring around a die the hinted move would capture: the hint's gold,
  /// in another shade.
  final Color hintCapture;

  @override
  BoardColors copyWith({
    Color? board,
    Color? boardEdge,
    Color? square,
    Color? blackDie,
    Color? blackDieEdge,
    Color? blackPips,
    Color? whiteDie,
    Color? whiteDieEdge,
    Color? whitePips,
    Color? lastMove,
    Color? captureTarget,
    Color? captureOption,
    Color? captureSelected,
    Color? hintTarget,
    Color? hintCapture,
  }) {
    return BoardColors(
      board: board ?? this.board,
      boardEdge: boardEdge ?? this.boardEdge,
      square: square ?? this.square,
      blackDie: blackDie ?? this.blackDie,
      blackDieEdge: blackDieEdge ?? this.blackDieEdge,
      blackPips: blackPips ?? this.blackPips,
      whiteDie: whiteDie ?? this.whiteDie,
      whiteDieEdge: whiteDieEdge ?? this.whiteDieEdge,
      whitePips: whitePips ?? this.whitePips,
      lastMove: lastMove ?? this.lastMove,
      captureTarget: captureTarget ?? this.captureTarget,
      captureOption: captureOption ?? this.captureOption,
      captureSelected: captureSelected ?? this.captureSelected,
      hintTarget: hintTarget ?? this.hintTarget,
      hintCapture: hintCapture ?? this.hintCapture,
    );
  }

  /// Blends towards [other] when the theme animates.
  @override
  BoardColors lerp(BoardColors? other, double t) {
    if (other == null) return this;
    return BoardColors(
      board: Color.lerp(board, other.board, t)!,
      boardEdge: Color.lerp(boardEdge, other.boardEdge, t)!,
      square: Color.lerp(square, other.square, t)!,
      blackDie: Color.lerp(blackDie, other.blackDie, t)!,
      blackDieEdge: Color.lerp(blackDieEdge, other.blackDieEdge, t)!,
      blackPips: Color.lerp(blackPips, other.blackPips, t)!,
      whiteDie: Color.lerp(whiteDie, other.whiteDie, t)!,
      whiteDieEdge: Color.lerp(whiteDieEdge, other.whiteDieEdge, t)!,
      whitePips: Color.lerp(whitePips, other.whitePips, t)!,
      lastMove: Color.lerp(lastMove, other.lastMove, t)!,
      captureTarget: Color.lerp(captureTarget, other.captureTarget, t)!,
      captureOption: Color.lerp(captureOption, other.captureOption, t)!,
      captureSelected: Color.lerp(captureSelected, other.captureSelected, t)!,
      hintTarget: Color.lerp(hintTarget, other.hintTarget, t)!,
      hintCapture: Color.lerp(hintCapture, other.hintCapture, t)!,
    );
  }
}
