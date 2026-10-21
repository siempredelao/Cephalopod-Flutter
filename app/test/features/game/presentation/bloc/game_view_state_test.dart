// Values are built at runtime on purpose, so equality is tested on distinct
// instances rather than on canonicalised constants.
// ignore_for_file: prefer_const_constructors

import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rules = CephalopodRules();

  GameViewState start() => GameViewState(
    game: rules.newGame(),
    phase: TurnPhase.awaitingPlacement(),
  );

  group('GameViewState', () {
    test('states with the same values are equal', () {
      expect(start(), start());
      expect(start().hashCode, start().hashCode);
      expect(start(), isNot(start().copyWith(lastMove: Move(Position(0, 0)))));
    });

    test('copyWith changes only the fields it is given', () {
      final move = Move(Position(2, 2));

      final next = start().copyWith(lastMove: move);

      expect(next.lastMove, move);
      expect(next.game, start().game);
      expect(next.phase, TurnPhase.awaitingPlacement());
    });

    test('copyWith can set a field back to null', () {
      final withMove = start().copyWith(lastMove: Move(Position(2, 2)));

      expect(withMove.copyWith(lastMove: null).lastMove, isNull);
    });

    test('prints its fields, for readable test failures', () {
      expect(start().toString(), startsWith('GameViewState(game: GameState('));
    });
  });
}
