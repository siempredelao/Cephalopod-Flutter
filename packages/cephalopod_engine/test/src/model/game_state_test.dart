// Values are built at runtime on purpose, so equality is tested on distinct
// instances rather than on canonicalised constants.
// ignore_for_file: prefer_const_constructors

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('GameState', () {
    GameState state({
      Board? board,
      GameStatus status = const InProgress(Player.black),
      GameConfig config = GameConfig.standard,
    }) => GameState(
      board: board ?? Board(size: 5),
      status: status,
      config: config,
    );

    test('uses the standard config by default', () {
      final withDefaults = GameState(
        board: Board(size: 5),
        status: InProgress(Player.black),
      );

      expect(withDefaults.config, GameConfig.standard);
    });

    test('states with the same board, status and config are equal', () {
      expect(state(), state());
      expect(state().hashCode, state().hashCode);
      expect(state(), isNot(state(board: Board(size: 3))));
      expect(state(), isNot(state(status: InProgress(Player.white))));
      expect(state(), isNot(state(config: GameConfig(maxCaptureSum: 5))));
    });

    test('prints its status, config and board', () {
      expect(
        state(board: Board(size: 1)).toString(),
        'GameState(status: InProgress(toMove: black), '
        'config: GameConfig(boardSize: 5, firstPlayer: black, '
        'maxCaptureSum: 6, minCaptureDice: 2), '
        'board: Board(size: 1, dice: {}))',
      );
    });
  });
}
