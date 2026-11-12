import 'dart:async';

import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/use_cases/suggest_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/computer_turns.dart';
import '../../../../helpers/use_case_fixture.dart';

/// [SuggestMove], run with a fixed agent against an in-memory repository:
/// which move it gives, and that it plays nothing.
void main() {
  final agentMove = Move(top);
  late UseCaseFixture fixture;
  late FixedMoveAgent agent;
  late List<Difficulty> difficulties;
  late int backgroundRuns;
  late SuggestMove suggestMove;

  /// Runs the agent here, and counts the runs.
  Future<R> countingRunner<M, R>(
    FutureOr<R> Function(M message) callback,
    M message,
  ) {
    backgroundRuns++;
    return runHere(callback, message);
  }

  setUp(() {
    fixture = UseCaseFixture();
    agent = FixedMoveAgent(agentMove);
    difficulties = [];
    backgroundRuns = 0;
    suggestMove = SuggestMove(
      agentFactory: (difficulty) {
        difficulties.add(difficulty);
        return agent;
      },
      backgroundRunner: countingRunner,
    );
  });

  test('gives the move the agent chooses, and plays nothing', () async {
    final start = await fixture.startNewGame(opponent: friend);
    final game = await fixture.play(start, Move(center));

    final move = await suggestMove(game);

    expect(agent.positions, [game.state]);
    expect(move, agentMove);
    expect(await fixture.repository.load(), fixture.saved(game));
  });

  test('asks the agent of the Hard level, in the background', () async {
    await suggestMove(await fixture.startNewGame(opponent: friend));

    expect(difficulties, [Difficulty.hard]);
    expect(backgroundRuns, 1);
  });

  test('suggests a move to the person against the computer', () async {
    final start = await fixture.startNewGame(opponent: computer);

    expect(await suggestMove(start), agentMove);
  });

  test('refuses a game that is over', () async {
    const oneSquare = GameConfig(boardSize: 1);
    final start = await fixture.startNewGame(
      config: oneSquare,
      opponent: friend,
    );
    final over = await fixture.play(start, Move(const Position(0, 0)));

    await expectLater(suggestMove(over), throwsArgumentError);
    expect(difficulties, isEmpty);
  });
}
