import 'package:cephalopod/features/game/data/game_record_json_codec.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

const String _config =
    '{"boardSize": 5, "firstPlayer": "black", '
    '"maxCaptureSum": 6, "minCaptureDice": 2}';

/// A save in the JSON format, with any part replaced to break it.
String _save({
  Object? version = 1,
  String config = _config,
  String moves = '[]',
}) {
  return '{"schemaVersion": $version, "config": $config, "moves": $moves}';
}

void main() {
  final codec = GameRecordJsonCodec();
  const center = Position(2, 2);
  const left = Position(2, 1);
  const right = Position(2, 3);
  final capture = Move(center, captures: {left, right});
  final moves = [Move(left), Move(right), capture];

  group('GameRecordJsonCodec', () {
    test('writes the format of docs/adr/0003', () {
      final record = GameRecord(moves: moves);

      expect(
        codec.encode(record),
        '{"schemaVersion":1,'
        '"config":{"boardSize":5,"firstPlayer":"black",'
        '"maxCaptureSum":6,"minCaptureDice":2},'
        '"moves":[{"row":2,"col":1,"captures":[]},'
        '{"row":2,"col":3,"captures":[]},'
        '{"row":2,"col":2,"captures":[[2,1],[2,3]]}]}',
      );
    });

    test('reads back what it writes', () {
      const config = GameConfig(boardSize: 3, firstPlayer: Player.white);
      final record = GameRecord(config: config, moves: moves);

      expect(codec.decode(codec.encode(record)), record);
    });

    test('reads a save with no moves', () {
      expect(codec.decode(_save()), GameRecord());
    });

    test('reads nothing from a save it does not understand', () {
      final saves = [
        'not json',
        '[]',
        _save(version: 2),
        _save(config: 'null'),
        _save(config: '{"boardSize": 5}'),
        _save(config: _config.replaceFirst('black', 'red')),
        _save(moves: '"none"'),
        _save(moves: '[7]'),
        _save(moves: '[{"row": 2}]'),
        _save(moves: '[{"row": 2, "col": 2, "captures": "none"}]'),
        _save(moves: '[{"row": 2, "col": 2, "captures": [[2]]}]'),
      ];

      for (final save in saves) {
        expect(codec.decode(save), isNull, reason: save);
      }
    });
  });
}
