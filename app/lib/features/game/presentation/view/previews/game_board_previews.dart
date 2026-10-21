import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/view/previews/board_preview_wrapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

const Position _top = Position(0, 2);
const Position _left = Position(0, 1);
const Position _right = Position(0, 3);
const Position _below = Position(1, 2);

@Preview(
  group: 'GameBoard',
  name: 'New game',
  size: Size(400, 400),
  wrapper: boardPreviewWrapper,
)
Widget newGamePreview() {
  final game = CephalopodRules().newGame();
  return _boardOf(_placing(game));
}

@Preview(
  group: 'GameBoard',
  name: 'Mid-game, last move marked',
  size: Size(400, 400),
  wrapper: boardPreviewWrapper,
)
Widget midGamePreview() {
  final game = _gameWith({
    const Position(0, 0): const Die(owner: Player.white, pips: 1),
    const Position(0, 2): const Die(owner: Player.black, pips: 2),
    const Position(1, 1): const Die(owner: Player.black, pips: 1),
    const Position(2, 0): const Die(owner: Player.black, pips: 6),
    const Position(2, 2): const Die(owner: Player.white, pips: 5),
    const Position(3, 2): const Die(owner: Player.black, pips: 4),
    const Position(4, 1): const Die(owner: Player.white, pips: 5),
  });
  final lastMove = Move(const Position(2, 2));
  return _boardOf(_placing(game, lastMove: lastMove));
}

/// Rule sheet Fig. 4: a die on the top centre square can capture three ways.
/// Player 1 has picked the 1 on the left.
@Preview(
  group: 'GameBoard',
  name: 'Choosing a capture (R5)',
  size: Size(400, 400),
  wrapper: boardPreviewWrapper,
)
Widget choosingCapturePreview() {
  final game = _gameWith({
    _left: const Die(owner: Player.white, pips: 1),
    _right: const Die(owner: Player.white, pips: 1),
    _below: const Die(owner: Player.black, pips: 5),
  });
  final options = [
    for (final move in CephalopodRules().legalMoves(game))
      if (move.position == _top) move.captures,
  ];
  final choosing = _placing(game).copyWith(
    phase: TurnPhase.choosingCapture(
      target: _top,
      options: options,
      selected: {_left},
      selectedSum: 1,
    ),
  );
  return _boardOf(choosing);
}

/// A standard game in progress, with [dice] on the board and Player 1 to
/// move.
GameState _gameWith(Map<Position, Die> dice) {
  return GameState(
    board: Board(size: GameConfig.standard.boardSize, dice: dice),
    status: const InProgress(Player.black),
  );
}

GameViewState _placing(GameState game, {Move? lastMove}) {
  return GameViewState(
    game: game,
    phase: const TurnPhase.awaitingPlacement(),
    lastMove: lastMove,
  );
}

Widget _boardOf(GameViewState state) {
  return GameBoard(state: state, onSquareTapped: (_) {});
}
