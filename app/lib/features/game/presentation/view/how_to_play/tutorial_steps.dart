import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/models/tutorial_step.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

const Position _centre = Position(2, 2);
const Position _above = Position(1, 2);
const Position _left = Position(2, 1);
const Position _right = Position(2, 3);
const Position _below = Position(3, 2);

/// The pages of the how-to-play tutorial, in order. Every example is a real
/// position, and the tests check it against the engine's rules.
final List<TutorialStep> tutorialSteps = [
  TutorialStep(
    title: 'Take turns',
    body:
        'Player 1 plays the coral dice and Player 2 the cream ones. On your '
        'turn, place one die on any empty square. You cannot pass.',
    example: _takingTurns(),
  ),
  TutorialStep(
    title: 'Nothing to capture? Place a 1',
    body:
        'A die touches the squares above, below, left and right of it, never '
        'diagonally. When no two of those dice add up to 6 or less, your new '
        'die shows 1.',
    example: _placingAOne(),
  ),
  TutorialStep(
    title: 'Capture when you can',
    body:
        'When two or more of those dice add up to 6 or less, you must '
        'capture them, whatever their colour.',
    example: _mustCapture(),
  ),
  TutorialStep(
    title: 'Your die shows the sum',
    body:
        'The captured dice leave the board, and your new die shows their '
        'total. Here, 2 + 3 = 5.',
    example: _showingTheSum(),
  ),
  TutorialStep(
    title: 'Choose your capture',
    body:
        'When more than one set adds up to 6 or less, you choose which: tap '
        'its dice, then Capture. Here, the two 1s, or a 1 with the 5.',
    example: _choosingACapture(),
  ),
  TutorialStep(
    title: 'Fill the board to win',
    body:
        'The game ends when every square is full. The player with more dice '
        'on the board wins: here, Player 1 by 13 to 12.',
    example: _fullBoard(),
  ),
];

GameViewState _takingTurns() {
  final dice = {
    const Position(0, 0): _cream(1),
    const Position(1, 3): _coral(1),
    const Position(3, 1): _coral(1),
    const Position(4, 4): _cream(1),
    _centre: _cream(1),
  };
  return _placing(dice, lastMove: _centre);
}

GameViewState _placingAOne() {
  final dice = {
    const Position(0, 4): _cream(2),
    _above: _coral(5),
    _left: _cream(4),
    const Position(4, 0): _cream(3),
    _centre: _coral(1),
  };
  return _placing(dice, lastMove: _centre);
}

GameViewState _mustCapture() {
  final dice = {
    _above: _coral(2),
    _left: _cream(3),
    _right: _cream(5),
    const Position(4, 4): _coral(1),
  };
  return _choosing(
    dice,
    options: [
      {_above, _left},
    ],
  );
}

GameViewState _showingTheSum() {
  final dice = {
    _right: _cream(5),
    const Position(4, 4): _coral(1),
    _centre: _coral(5),
  };
  return _placing(dice, lastMove: _centre);
}

GameViewState _choosingACapture() {
  final dice = {_left: _cream(1), _right: _cream(1), _below: _coral(5)};
  return _choosing(
    dice,
    options: [
      {_left, _right},
      {_left, _below},
      {_right, _below},
    ],
    selected: {_left},
  );
}

GameViewState _fullBoard() {
  final size = GameConfig.standard.boardSize;
  final dice = {
    for (var row = 0; row < size; row++)
      for (var col = 0; col < size; col++)
        Position(row, col): _fullBoardDieAt(row, col),
  };
  const result = Finished(winner: Player.black, blackDice: 13, whiteDice: 12);
  final board = Board(size: size, dice: dice);
  final game = GameState(board: board, status: result);
  return GameViewState(game: game, phase: const TurnPhase.gameEnded(result));
}

/// Player 1 on the squares where row + column is even, so 13 dice to 12,
/// with the pips running through 1 to 6.
Die _fullBoardDieAt(int row, int col) {
  final pips = (row + col * 2) % 6 + 1;
  return (row + col).isEven ? _coral(pips) : _cream(pips);
}

Die _coral(int pips) => Die(owner: Player.black, pips: pips);

Die _cream(int pips) => Die(owner: Player.white, pips: pips);

GameState _gameWith(Map<Position, Die> dice) {
  return GameState(
    board: Board(size: GameConfig.standard.boardSize, dice: dice),
    status: const InProgress(Player.black),
  );
}

GameViewState _placing(Map<Position, Die> dice, {required Position lastMove}) {
  return GameViewState(
    game: _gameWith(dice),
    phase: const TurnPhase.awaitingPlacement(),
    lastMove: Move(lastMove),
  );
}

GameViewState _choosing(
  Map<Position, Die> dice, {
  required List<Set<Position>> options,
  Set<Position> selected = const {},
}) {
  return GameViewState(
    game: _gameWith(dice),
    phase: TurnPhase.choosingCapture(
      target: _centre,
      options: options,
      selected: selected,
    ),
  );
}
