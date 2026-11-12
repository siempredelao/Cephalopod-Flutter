import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/use_case_fixture.dart';

/// `PlayMove`, run against the real engine and an in-memory repository: what
/// it returns, and what it leaves saved.
void main() {
  late UseCaseFixture fixture;

  setUp(() {
    fixture = UseCaseFixture();
  });

  test('plays the move and saves the game with it', () async {
    final start = await fixture.startNewGame(opponent: friend);

    final game = await fixture.play(start, Move(center));

    expect(game.record.moves, [Move(center)]);
    expect(game.state.board.dice[center]?.owner, Player.black);
    expect(await fixture.repository.load(), fixture.saved(game));
  });

  test('keeps the opponent', () async {
    final start = await fixture.startNewGame(opponent: computer);

    final game = await fixture.play(start, Move(center));

    expect(game.opponent, computer);
    expect(await fixture.repository.load(), fixture.saved(game));
  });

  test('R2: refuses an illegal move and saves nothing', () async {
    final start = await fixture.startNewGame(opponent: friend);
    final game = await fixture.play(start, Move(center));

    final result = await fixture.playMove(game, Move(center));

    expect(result, isA<Err<CurrentGame, IllegalMove>>());
    expect(await fixture.repository.load(), fixture.saved(game));
  });
}
