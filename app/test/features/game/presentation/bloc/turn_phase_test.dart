// Values are built at runtime on purpose, so equality is tested on distinct
// instances rather than on canonicalised constants.
// ignore_for_file: prefer_const_constructors

import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const left = Position(0, 1);
  const right = Position(0, 3);
  const below = Position(1, 2);

  ChoosingCapture choosing({Set<Position>? first}) => ChoosingCapture(
    target: Position(0, 2),
    options: [
      first ?? {left, right},
      {left, below},
    ],
  );

  group('TurnPhase', () {
    test('choosing a capture starts with nothing selected', () {
      final phase = choosing();

      expect(phase.selected, isEmpty);
      expect(phase.selectedSum, 0);
      expect(phase.canConfirm, isFalse);
    });

    test('phases with the same values are equal; sets ignore order', () {
      expect(choosing(), choosing(first: {right, left}));
      expect(choosing().hashCode, choosing(first: {right, left}).hashCode);
      expect(choosing(), isNot(choosing(first: {right, below})));
    });

    test('copyWith changes only the fields it is given', () {
      final phase = choosing().copyWith(selected: {left}, selectedSum: 1);

      expect(phase.selected, {left});
      expect(phase.selectedSum, 1);
      expect(phase.target, choosing().target);
      expect(phase.options, choosing().options);
    });

    test('collections cannot be changed after creation', () {
      expect(() => choosing().options.add({}), throwsUnsupportedError);
      expect(() => choosing().selected.add(left), throwsUnsupportedError);
    });

    test('a switch over the phases must handle every phase', () {
      String describe(TurnPhase phase) => switch (phase) {
        AwaitingPlacement() => 'place a die',
        ChoosingCapture(:final options) => 'pick 1 of ${options.length}',
        GameEnded(:final result) => '${result.winner.name} won',
      };
      const result = Finished(winner: Player.white, blackDice: 4, whiteDice: 5);

      expect(describe(TurnPhase.awaitingPlacement()), 'place a die');
      expect(describe(choosing()), 'pick 1 of 2');
      expect(describe(TurnPhase.gameEnded(result)), 'white won');
    });
  });
}
