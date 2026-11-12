import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/saved_game_summary_mapper.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = SavedGameSummaryMapper();

  /// A 3 × 3 game with two black dice and one white, black to move.
  final state = stateFromAscii('''
    b1 .  .
    .  w2 .
    .  .  b3
  ''', toMove: Player.black);

  CurrentGame gameAgainst(Opponent opponent, {GameState? at}) => (
    record: GameRecord(config: const GameConfig(boardSize: 3)),
    opponent: opponent,
    state: at ?? state,
  );

  group('SavedGameSummaryMapper', () {
    test('keeps the board of the game', () {
      final summary = mapper.map(gameAgainst(const FriendOpponent()));

      expect(summary.board, state.board);
    });

    test("counts each side's dice, and says who is to move", () {
      final summary = mapper.map(gameAgainst(const FriendOpponent()));

      expect(summary.black.dice, 2);
      expect(summary.black.toMove, isTrue);
      expect(summary.white.dice, 1);
      expect(summary.white.toMove, isFalse);
    });

    test('names the sides as two people against a friend, with no level', () {
      final summary = mapper.map(gameAgainst(const FriendOpponent()));

      expect(
        summary.black.side,
        const SideUi(player: PlayerUi.one, role: RoleUi.player),
      );
      expect(
        summary.white.side,
        const SideUi(player: PlayerUi.two, role: RoleUi.player),
      );
      expect(summary.computerLevel, isNull);
    });

    test('names the person and the computer, with its level', () {
      const computer = ComputerOpponent(
        difficulty: Difficulty.hard,
        player: Player.white,
      );

      final summary = mapper.map(gameAgainst(computer));

      expect(summary.black.side.role, RoleUi.person);
      expect(summary.white.side.role, RoleUi.computer);
      expect(summary.computerLevel, ComputerLevel.hard);
    });

    test('maps every difficulty to its own level', () {
      final levels = [
        for (final difficulty in Difficulty.values)
          mapper
              .map(
                gameAgainst(
                  ComputerOpponent(
                    difficulty: difficulty,
                    player: Player.white,
                  ),
                ),
              )
              .computerLevel,
      ];

      expect(levels, ComputerLevel.values);
    });

    test('says the other side is to move when white is', () {
      final whiteToMove = stateFromAscii('''
        b1 .  .
        .  .  .
        .  .  .
      ''', toMove: Player.white);

      final summary = mapper.map(
        gameAgainst(const FriendOpponent(), at: whiteToMove),
      );

      expect(summary.black.toMove, isFalse);
      expect(summary.white.toMove, isTrue);
    });
  });
}
