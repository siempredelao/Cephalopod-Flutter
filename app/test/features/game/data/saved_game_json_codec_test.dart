import 'package:cephalopod/features/game/data/saved_game_json_codec.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

const String _config =
    '{"boardSize": 5, "firstPlayer": "black", '
    '"maxCaptureSum": 6, "minCaptureDice": 2}';

const String _friend = '{"type": "friend"}';

/// A save in the JSON format, with any part replaced to break it.
String _save({
  Object? version = 1,
  String config = _config,
  String opponent = _friend,
  String moves = '[]',
}) {
  return '{"schemaVersion": $version, "config": $config, '
      '"opponent": $opponent, "moves": $moves}';
}

void main() {
  final codec = SavedGameJsonCodec();
  const center = Position(2, 2);
  const left = Position(2, 1);
  const right = Position(2, 3);
  final capture = Move(center, captures: {left, right});
  final moves = [Move(left), Move(right), capture];
  const friend = FriendOpponent();
  const computer = ComputerOpponent(
    difficulty: Difficulty.hard,
    player: Player.white,
  );

  group('SavedGameJsonCodec', () {
    test('writes the move log of docs/adr/0003, with the opponent', () {
      final savedGame = (record: GameRecord(moves: moves), opponent: computer);

      expect(
        codec.encode(savedGame),
        '{"schemaVersion":1,'
        '"config":{"boardSize":5,"firstPlayer":"black",'
        '"maxCaptureSum":6,"minCaptureDice":2},'
        '"opponent":{"type":"computer","difficulty":"hard","player":"white"},'
        '"moves":[{"row":2,"col":1,"captures":[]},'
        '{"row":2,"col":3,"captures":[]},'
        '{"row":2,"col":2,"captures":[[2,1],[2,3]]}]}',
      );
    });

    test('reads back what it writes, for every opponent', () {
      const config = GameConfig(boardSize: 3, firstPlayer: Player.white);
      final record = GameRecord(config: config, moves: moves);

      for (final opponent in [friend, computer]) {
        final savedGame = (record: record, opponent: opponent);

        expect(codec.decode(codec.encode(savedGame)), savedGame);
      }
    });

    test('reads a save with no moves', () {
      expect(codec.decode(_save()), (record: GameRecord(), opponent: friend));
    });

    test('reads nothing from a save it does not understand', () {
      final saves = [
        'not json',
        '[]',
        _save(version: 2),
        _save(version: '"1"'),
        _save(config: 'null'),
        _save(config: '{"boardSize": 5}'),
        _save(config: _config.replaceFirst('black', 'red')),
        _save(config: _config.replaceFirst('"black"', '1')),
        _save(config: _config.replaceFirst('5', '"5"')),
        '{"schemaVersion": 1, "config": $_config, "moves": []}',
        _save(opponent: 'null'),
        _save(opponent: '{"type": "stranger"}'),
        _save(opponent: '{"type": "computer", "player": "white"}'),
        _save(opponent: '{"type": "computer", "difficulty": "hard"}'),
        _save(
          opponent: '{"type": "computer", "difficulty": 3, "player": "white"}',
        ),
        _save(
          opponent:
              '{"type": "computer", "difficulty": "expert", '
              '"player": "white"}',
        ),
        _save(moves: '"none"'),
        _save(moves: '[7]'),
        _save(moves: '[{"row": 2}]'),
        _save(moves: '[{"row": "2", "col": 2, "captures": []}]'),
        _save(moves: '[{"row": 2, "col": 2, "captures": "none"}]'),
        _save(moves: '[{"row": 2, "col": 2, "captures": [[2]]}]'),
      ];

      for (final save in saves) {
        expect(codec.decode(save), isNull, reason: save);
      }
    });
  });
}
