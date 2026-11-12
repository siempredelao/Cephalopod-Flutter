import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/use_case_fixture.dart';

/// `ResumeGame`, run against the real engine and an in-memory repository:
/// what it returns, and what it leaves saved.
void main() {
  late UseCaseFixture fixture;

  setUp(() {
    fixture = UseCaseFixture();
  });

  test('has nothing to resume before a game is saved', () async {
    expect(await fixture.resumeGame(), isNull);
  });

  test('rebuilds the saved game from its moves', () async {
    final start = await fixture.startNewGame(opponent: computer);
    final first = await fixture.play(start, Move(center));
    final second = await fixture.play(first, Move(top));

    expect(await fixture.resumeGame(), second);
  });

  test('clears a save it cannot replay, and starts nothing', () async {
    final corrupt = GameRecord(moves: [Move(center), Move(center)]);
    await fixture.repository.save((record: corrupt, opponent: friend));

    expect(await fixture.resumeGame(), isNull);
    expect(await fixture.repository.load(), isNull);
  });
}
