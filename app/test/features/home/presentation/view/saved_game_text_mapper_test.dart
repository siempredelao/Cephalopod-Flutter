import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod/features/home/presentation/bloc/saved_game_ui_mapper.dart';
import 'package:cephalopod/features/home/presentation/models/saved_game_ui.dart';
import 'package:cephalopod/features/home/presentation/view/saved_game_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/saved_game_summary.dart';
import '../../../../helpers/translations.dart';

void main() {
  const mapper = SavedGameTextMapper();

  /// The sample game against the computer, Hard, with 5 dice each and the
  /// person to move.
  final againstComputer = const SavedGameUiMapper().map(
    savedGameSummary.copyWith(
      black: (
        side: const SideUi(player: PlayerUi.one, role: RoleUi.person),
        dice: 5,
        toMove: true,
      ),
      white: (
        side: const SideUi(player: PlayerUi.two, role: RoleUi.computer),
        dice: 5,
        toMove: false,
      ),
    ),
  );

  /// A game between two people, Player 2 to move, Player 1 with 7 dice and
  /// Player 2 with 4.
  final againstFriend = const SavedGameUiMapper().map(
    savedGameSummary.copyWith(
      black: (
        side: const SideUi(player: PlayerUi.one, role: RoleUi.player),
        dice: 7,
        toMove: false,
      ),
      white: (
        side: const SideUi(player: PlayerUi.two, role: RoleUi.player),
        dice: 4,
        toMove: true,
      ),
      computerLevel: null,
    ),
  );

  group('SavedGameTextMapper', () {
    group('in English', () {
      test('words the computer and its level', () {
        expect(
          mapper.opponentOf(againstComputer, english),
          'vs Computer · Hard',
        );
      });

      test('words every level', () {
        final levels = {
          for (final level in ComputerLevel.values)
            mapper.opponentOf(
              SavedGameUi(
                board: againstComputer.board,
                black: againstComputer.black,
                white: againstComputer.white,
                computerLevel: level,
              ),
              english,
            ),
        };

        expect(levels, {
          'vs Computer · Easy',
          'vs Computer · Medium',
          'vs Computer · Hard',
        });
      });

      test('words a friend', () {
        expect(mapper.opponentOf(againstFriend, english), 'vs a friend');
      });

      test("words the person's turn, and each side's dice", () {
        expect(
          mapper.detailsOf(againstComputer, english),
          'Your turn · you\u00a05, computer\u00a05',
        );
      });

      test("words the computer's turn", () {
        final computersTurn = againstComputer.copyWith(
          black: (side: againstComputer.black.side, dice: 5, toMove: false),
          white: (side: againstComputer.white.side, dice: 5, toMove: true),
        );

        expect(
          mapper.detailsOf(computersTurn, english),
          startsWith("Computer's turn"),
        );
      });

      test('words a turn between two people by the player', () {
        expect(
          mapper.detailsOf(againstFriend, english),
          "Player 2's turn · Player 1:\u00a07, Player 2:\u00a04",
        );
      });

      test('says everything for a screen reader', () {
        expect(
          mapper.spokenOf(againstComputer, english),
          'Continue. vs Computer · Hard. Your turn. '
          'You: 5 dice. Computer: 5 dice.',
        );
      });
    });

    group('in Spanish', () {
      test('words the computer and its level', () {
        expect(
          mapper.opponentOf(againstComputer, spanish),
          'contra el ordenador · Difícil',
        );
      });

      test('words a friend', () {
        expect(mapper.opponentOf(againstFriend, spanish), 'contra un amigo');
      });

      test("words the turn and each side's dice", () {
        expect(
          mapper.detailsOf(againstComputer, spanish),
          'Tu turno · tú\u00a05, ordenador\u00a05',
        );
        expect(
          mapper.detailsOf(againstFriend, spanish),
          'Turno del Jugador 2 · Jugador 1:\u00a07, Jugador 2:\u00a04',
        );
      });

      test('says everything for a screen reader', () {
        expect(
          mapper.spokenOf(againstComputer, spanish),
          'Continuar. contra el ordenador · Difícil. Tu turno. '
          'Tú: 5 dados. Ordenador: 5 dados.',
        );
      });
    });
  });
}
