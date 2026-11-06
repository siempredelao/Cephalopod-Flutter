import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/view/opponent_query_codec.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = OpponentQueryCodec();
  const friend = FriendOpponent();
  const computer = ComputerOpponent(
    difficulty: Difficulty.hard,
    player: Player.white,
  );

  group('OpponentQueryCodec', () {
    test('needs no parameters for a friend', () {
      expect(codec.encode(friend), isEmpty);
    });

    test("names the computer's colour and difficulty", () {
      expect(codec.encode(computer), {
        'computer': 'white',
        'difficulty': 'hard',
      });
    });

    test('reads back what it writes, for every opponent', () {
      for (final opponent in [friend, computer]) {
        expect(codec.decode(codec.encode(opponent)), opponent);
      }
    });

    test('reads a friend from parameters that name no computer', () {
      final parameters = [
        <String, String>{},
        {'resume': 'true'},
        {'computer': 'white'},
        {'difficulty': 'hard'},
        {'computer': 'red', 'difficulty': 'hard'},
        {'computer': 'white', 'difficulty': 'expert'},
      ];

      for (final query in parameters) {
        expect(codec.decode(query), friend, reason: '$query');
      }
    });
  });
}
