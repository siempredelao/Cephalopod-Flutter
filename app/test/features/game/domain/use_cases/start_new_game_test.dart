import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/use_case_fixture.dart';

/// `StartNewGame`, run against the real engine and an in-memory repository:
/// what it returns, and what it leaves saved.
void main() {
  late UseCaseFixture fixture;

  setUp(() {
    fixture = UseCaseFixture();
  });

  test('starts and saves a new game under the config', () async {
    const config = GameConfig(boardSize: 3);

    final game = await fixture.startNewGame(config: config, opponent: friend);

    expect(game.state, fixture.rules.newGame(config));
    expect(game.record, GameRecord(config: config));
    expect(await fixture.repository.load(), fixture.saved(game));
  });

  test('saves the opponent with the game', () async {
    final game = await fixture.startNewGame(opponent: computer);

    expect(game.opponent, computer);
    expect(await fixture.repository.load(), fixture.saved(game));
  });

  test('replaces the saved game', () async {
    final start = await fixture.startNewGame(opponent: friend);
    final old = await fixture.play(start, Move(center));

    final game = await fixture.startNewGame(opponent: friend);

    expect(game.record.moves, isEmpty);
    expect(await fixture.repository.load(), isNot(fixture.saved(old)));
  });
}
