import 'dart:async';

import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/use_cases/choose_agent_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/computer_turns.dart';
import '../../../../helpers/use_case_fixture.dart';

/// [ChooseAgentMove], run with a fixed agent against an in-memory
/// repository: which move it gives, and that it saves nothing.
void main() {
  final agentMove = Move(top);
  late UseCaseFixture fixture;
  late FixedMoveAgent agent;
  late List<Difficulty> difficulties;
  late int backgroundRuns;
  late ChooseAgentMove chooseAgentMove;

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
    chooseAgentMove = ChooseAgentMove(
      agentFactory: (difficulty) {
        difficulties.add(difficulty);
        return agent;
      },
      backgroundRunner: countingRunner,
    );
  });

  /// A game against [opponent] after black's first move, so white is to
  /// move: the computer's turn, if it plays white.
  Future<CurrentGame> computerToMove([Opponent opponent = computer]) async {
    final start = await fixture.startNewGame(opponent: opponent);
    return fixture.play(start, Move(center));
  }

  test('gives the move the agent chooses, and saves nothing', () async {
    final game = await computerToMove();

    final move = await chooseAgentMove(game);

    expect(agent.positions, [game.state]);
    expect(move, agentMove);
    expect(await fixture.repository.load(), fixture.saved(game));
  });

  test('lets the agent choose in the background', () async {
    await chooseAgentMove(await computerToMove());

    expect(backgroundRuns, 1);
  });

  test("knows when it is the computer's turn", () async {
    final start = await fixture.startNewGame(opponent: computer);
    final againstFriend = await computerToMove(friend);

    expect(chooseAgentMove.isComputerTurn(start), isFalse);
    expect(chooseAgentMove.isComputerTurn(await computerToMove()), isTrue);
    expect(chooseAgentMove.isComputerTurn(againstFriend), isFalse);
  });

  test("asks for the agent of the computer's difficulty", () async {
    for (final difficulty in Difficulty.values) {
      final opponent = ComputerOpponent(
        difficulty: difficulty,
        player: Player.white,
      );
      await chooseAgentMove(await computerToMove(opponent));
    }

    expect(difficulties, Difficulty.values);
  });

  test('refuses a game against a friend', () async {
    final game = await computerToMove(friend);

    await expectLater(chooseAgentMove(game), throwsArgumentError);
  });

  test("refuses when it is the person's turn", () async {
    final start = await fixture.startNewGame(opponent: computer);

    await expectLater(chooseAgentMove(start), throwsArgumentError);
  });

  test('refuses a game that is over', () async {
    const oneSquare = GameConfig(boardSize: 1);
    final start = await fixture.startNewGame(
      config: oneSquare,
      opponent: computer,
    );
    final over = await fixture.play(start, Move(const Position(0, 0)));

    await expectLater(chooseAgentMove(over), throwsArgumentError);
  });
}
