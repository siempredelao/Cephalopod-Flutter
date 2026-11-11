import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/dice_tally_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/dice_tally_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = DiceTallyUiMapper();
  const friend = FriendOpponent();
  // The computer plays White, so the person plays Black.
  const computer = ComputerOpponent(
    difficulty: Difficulty.easy,
    player: Player.white,
  );
  const playerOne = SideUi(player: PlayerUi.one, role: RoleUi.player);
  const playerTwo = SideUi(player: PlayerUi.two, role: RoleUi.player);

  /// The count between two people: Player 1 with [one] dice, Player 2 with
  /// [two], and [toMove] to move, if anyone is.
  DiceTallyUi tally(int one, int two, {required Player? toMove}) {
    return DiceTallyUi(
      playerOne: SideTallyUi(
        side: playerOne,
        dice: one,
        toMove: toMove == Player.black,
      ),
      playerTwo: SideTallyUi(
        side: playerTwo,
        dice: two,
        toMove: toMove == Player.white,
      ),
    );
  }

  group('DiceTallyUiMapper', () {
    test('counts no dice on an empty board, Player 1 to move', () {
      final game = CephalopodRules().newGame();

      expect(mapper.map(game, friend), tally(0, 0, toMove: Player.black));
    });

    test("counts each side's dice mid-game, whatever their pips", () {
      final game = stateFromAscii('''
        b1 .  w6 .  .
        .  b5 .  .  .
        .  .  w2 .  b3
        .  .  .  .  .
        .  .  .  .  .
      ''', toMove: Player.white);

      expect(mapper.map(game, friend), tally(3, 2, toMove: Player.white));
    });

    test('counts what is left after a capture', () {
      final rules = CephalopodRules();
      final before = stateFromAscii('''
        .  w1 .
        w1 .  .
        .  .  .
      ''', toMove: Player.black);
      const corner = Position(0, 0);
      final capture = rules
          .legalMoves(before)
          .firstWhere((move) => move.position == corner);

      final after = switch (rules.apply(before, capture)) {
        Ok(:final value) => value,
        Err(:final error) => fail('$error'),
      };

      // Black's new die took both of White's.
      expect(mapper.map(after, friend), tally(1, 0, toMove: Player.white));
    });

    test('has no side to move once the game is over', () {
      final game = stateFromAscii('''
        b1 w1 b1
        w1 b1 w1
        b1 w1 b1
      ''', toMove: Player.black);

      expect(game.status, isA<Finished>());
      expect(mapper.map(game, friend), tally(5, 4, toMove: null));
    });

    test('names the person and the computer against the computer', () {
      final game = stateFromAscii('''
        b1 .  .
        .  .  .
        .  .  .
      ''', toMove: Player.white);

      expect(
        mapper.map(game, computer),
        const DiceTallyUi(
          playerOne: SideTallyUi(
            side: SideUi(player: PlayerUi.one, role: RoleUi.person),
            dice: 1,
            toMove: false,
          ),
          playerTwo: SideTallyUi(
            side: SideUi(player: PlayerUi.two, role: RoleUi.computer),
            dice: 0,
            toMove: true,
          ),
        ),
      );
    });
  });
}
