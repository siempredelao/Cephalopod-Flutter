import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_topic.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

const Position _centre = Position(2, 2);
const Position _above = Position(1, 2);
const Position _left = Position(2, 1);
const Position _right = Position(2, 3);
const Position _below = Position(3, 2);

/// The pages of the how-to-play tutorial, in order: one per [TutorialTopic].
/// Every example is a real position, and the tests check it against the
/// engine's rules.
///
/// The words for each topic are in the translation files, and they describe
/// these examples: their colours, "2 + 3 = 5", "13 to 12". A test checks that
/// the numbers still match after a change here.
final List<TutorialStep> tutorialSteps = [
  TutorialStep(topic: TutorialTopic.takeTurns, example: _takingTurns()),
  TutorialStep(topic: TutorialTopic.placeAOne, example: _placingAOne()),
  TutorialStep(
    topic: TutorialTopic.captureWhenYouCan,
    example: _mustCapture(),
  ),
  TutorialStep(
    topic: TutorialTopic.dieShowsTheSum,
    example: _showingTheSum(),
  ),
  TutorialStep(
    topic: TutorialTopic.chooseYourCapture,
    example: _choosingACapture(),
  ),
  TutorialStep(topic: TutorialTopic.fillTheBoard, example: _fullBoard()),
];

TutorialExample _takingTurns() {
  final dice = {
    const Position(0, 0): _cream(1),
    const Position(1, 3): _coral(1),
    const Position(3, 1): _coral(1),
    const Position(4, 4): _cream(1),
    _centre: _cream(1),
  };
  return _placing(dice, lastMove: _centre);
}

TutorialExample _placingAOne() {
  final dice = {
    const Position(0, 4): _cream(2),
    _above: _coral(5),
    _left: _cream(4),
    const Position(4, 0): _cream(3),
    _centre: _coral(1),
  };
  return _placing(dice, lastMove: _centre);
}

TutorialExample _mustCapture() {
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

TutorialExample _showingTheSum() {
  final dice = {
    _right: _cream(5),
    const Position(4, 4): _coral(1),
    _centre: _coral(5),
  };
  return _placing(dice, lastMove: _centre);
}

TutorialExample _choosingACapture() {
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

TutorialExample _fullBoard() {
  final size = GameConfig.standard.boardSize;
  final dice = {
    for (var row = 0; row < size; row++)
      for (var col = 0; col < size; col++)
        Position(row, col): _fullBoardDieAt(row, col),
  };
  const result = Finished(winner: Player.black, blackDice: 13, whiteDice: 12);
  final board = Board(size: size, dice: dice);
  final game = GameState(board: board, status: result);
  return (game: game, phase: const TurnPhase.gameEnded(result), lastMove: null);
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

TutorialExample _placing(
  Map<Position, Die> dice, {
  required Position lastMove,
}) {
  return (
    game: _gameWith(dice),
    phase: const TurnPhase.awaitingPlacement(),
    lastMove: Move(lastMove),
  );
}

TutorialExample _choosing(
  Map<Position, Die> dice, {
  required List<Set<Position>> options,
  Set<Position> selected = const {},
}) {
  return (
    game: _gameWith(dice),
    phase: TurnPhase.choosingCapture(
      target: _centre,
      options: options,
      selected: selected,
    ),
    lastMove: null,
  );
}
