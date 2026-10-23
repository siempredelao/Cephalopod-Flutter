// Values are built at runtime on purpose, so equality is tested on distinct
// instances rather than on canonicalised constants.
// ignore_for_file: prefer_const_constructors

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('GameConfig', () {
    test('standard is the published game', () {
      expect(GameConfig.standard.boardSize, 5);
      expect(GameConfig.standard.firstPlayer, Player.black);
      expect(GameConfig.standard.maxCaptureSum, 6);
      expect(GameConfig.standard.minCaptureDice, 2);
    });

    test('configs with the same values are equal', () {
      expect(GameConfig(), GameConfig.standard);
      expect(GameConfig().hashCode, GameConfig.standard.hashCode);
      expect(GameConfig(boardSize: 3), isNot(GameConfig.standard));
      expect(GameConfig(firstPlayer: Player.white), isNot(GameConfig()));
      expect(GameConfig(maxCaptureSum: 5), isNot(GameConfig()));
      expect(GameConfig(minCaptureDice: 3), isNot(GameConfig()));
    });

    test('prints every value', () {
      expect(
        GameConfig().toString(),
        'GameConfig(boardSize: 5, firstPlayer: black, maxCaptureSum: 6, '
        'minCaptureDice: 2)',
      );
    });
  });
}
