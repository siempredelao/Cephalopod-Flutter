import 'package:cephalopod/features/game/domain/use_cases/game_to_continue.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/use_case_fixture.dart';

/// `GameToContinue`, run against the real engine and an in-memory
/// repository.
void main() {
  late UseCaseFixture fixture;
  late GameToContinue gameToContinue;

  setUp(() {
    fixture = UseCaseFixture();
    gameToContinue = GameToContinue(resumeGame: fixture.resumeGame);
  });

  test('has no game when nothing is saved', () async {
    expect(await gameToContinue(), isNull);
  });

  test('has no game for a new game with no moves yet', () async {
    await fixture.startNewGame(opponent: friend);

    expect(await gameToContinue(), isNull);
  });

  test('gives the saved game once a move is played', () async {
    final start = await fixture.startNewGame(opponent: friend);
    final played = await fixture.play(start, Move(center));

    expect(await gameToContinue(), played);
  });

  test('R8: has no game once the game is over', () async {
    const oneSquare = GameConfig(boardSize: 1);
    final start = await fixture.startNewGame(
      config: oneSquare,
      opponent: friend,
    );
    await fixture.play(start, Move(const Position(0, 0)));

    expect(await gameToContinue(), isNull);
  });
}
