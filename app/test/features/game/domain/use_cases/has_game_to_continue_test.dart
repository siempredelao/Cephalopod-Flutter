import 'package:cephalopod/features/game/domain/use_cases/has_game_to_continue.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/use_case_fixture.dart';

/// [HasGameToContinue], run against the real engine and an in-memory
/// repository.
void main() {
  late UseCaseFixture fixture;
  late HasGameToContinue hasGameToContinue;

  setUp(() {
    fixture = UseCaseFixture();
    hasGameToContinue = HasGameToContinue(resumeGame: fixture.resumeGame);
  });

  test('says no when nothing is saved', () async {
    expect(await hasGameToContinue(), isFalse);
  });

  test('says no for a new game with no moves yet', () async {
    await fixture.startNewGame(opponent: friend);

    expect(await hasGameToContinue(), isFalse);
  });

  test('says yes once a move is played', () async {
    final start = await fixture.startNewGame(opponent: friend);
    await fixture.play(start, Move(center));

    expect(await hasGameToContinue(), isTrue);
  });

  test('R8: says no once the game is over', () async {
    const oneSquare = GameConfig(boardSize: 1);
    final start = await fixture.startNewGame(
      config: oneSquare,
      opponent: friend,
    );
    await fixture.play(start, Move(const Position(0, 0)));

    expect(await hasGameToContinue(), isFalse);
  });
}
