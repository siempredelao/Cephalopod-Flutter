import 'package:cephalopod/features/game/domain/use_cases/undo_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/counting_game_repository.dart';
import '../../../../helpers/use_case_fixture.dart';

/// [UndoMove], run against the real engine and an in-memory repository: what
/// it returns, and what it leaves saved.
void main() {
  late UseCaseFixture fixture;

  setUp(() {
    fixture = UseCaseFixture();
  });

  test('takes back the last move and saves the game without it', () async {
    final start = await fixture.startNewGame(opponent: computer);
    final first = await fixture.play(start, Move(center));
    final second = await fixture.play(first, Move(top));

    final undone = await fixture.undoMove(second);

    expect(undone, first);
    expect(await fixture.repository.load(), fixture.saved(first));
  });

  test('leaves a game with no moves as it is', () async {
    final start = await fixture.startNewGame(opponent: friend);

    expect(await fixture.undoMove(start), start);
  });

  test('takes back several moves with one save', () async {
    final counting = CountingGameRepository();
    final undoTwo = UndoMove(
      cephalopodRules: fixture.rules,
      gameRepository: counting,
    );
    final start = await fixture.startNewGame(opponent: computer);
    final first = await fixture.play(start, Move(center));
    final third = await fixture.play(
      await fixture.play(first, Move(top)),
      Move(const Position(4, 4)),
    );

    final undone = await undoTwo(third, count: 2);

    expect(undone, first);
    expect(await counting.load(), fixture.saved(first));
    expect(counting.saves, 1);
  });

  test('takes back every move when asked for more', () async {
    final start = await fixture.startNewGame(opponent: friend);
    final first = await fixture.play(start, Move(center));

    final undone = await fixture.undoMove(first, count: 5);

    expect(undone, start);
    expect(await fixture.repository.load(), fixture.saved(start));
  });

  test('refuses a negative count', () async {
    final start = await fixture.startNewGame(opponent: friend);
    final first = await fixture.play(start, Move(center));

    await expectLater(fixture.undoMove(first, count: -1), throwsRangeError);
  });

  test('fails loudly on a record its moves could not build', () async {
    final start = await fixture.startNewGame(opponent: friend);
    final moves = [Move(center), Move(center), Move(top)];
    final forged = (
      record: GameRecord(moves: moves),
      opponent: friend,
      state: start.state,
    );

    expect(fixture.undoMove(forged), throwsStateError);
  });
}
