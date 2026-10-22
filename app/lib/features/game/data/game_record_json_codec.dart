import 'dart:convert';

import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns a [GameRecord] into the saved JSON format of docs/adr/0003, and
/// back:
///
/// ```json
/// {
///   "schemaVersion": 1,
///   "config": {"boardSize": 5, "firstPlayer": "black", …},
///   "moves": [{"row": 0, "col": 1, "captures": [[0, 0], [0, 2]]}]
/// }
/// ```
///
/// Reading never throws: anything malformed gives `null`, so a corrupted
/// save starts a fresh game instead of crashing the app. Whether the moves
/// are legal is for `CephalopodRules.replay` to decide.
final class GameRecordJsonCodec {
  /// The format version written into every save. A save with another
  /// version is not read.
  static const int schemaVersion = 1;

  String encode(GameRecord record) {
    final config = record.config;
    final json = {
      'schemaVersion': schemaVersion,
      'config': {
        'boardSize': config.boardSize,
        'firstPlayer': config.firstPlayer.name,
        'maxCaptureSum': config.maxCaptureSum,
        'minCaptureDice': config.minCaptureDice,
      },
      'moves': [for (final move in record.moves) _encodeMove(move)],
    };
    return jsonEncode(json);
  }

  /// The record in [json], or `null` when it is not a save this version can
  /// read.
  GameRecord? decode(String json) {
    final Object? data;
    try {
      data = jsonDecode(json);
    } on FormatException {
      return null;
    }
    if (data is! Map<String, Object?>) return null;
    if (data['schemaVersion'] != schemaVersion) return null;
    final config = _decodeConfig(data['config']);
    final moves = _decodeMoves(data['moves']);
    if (config == null || moves == null) return null;
    return GameRecord(config: config, moves: moves);
  }

  Map<String, Object?> _encodeMove(Move move) {
    return {
      'row': move.position.row,
      'col': move.position.col,
      'captures': [
        for (final square in move.captures) [square.row, square.col],
      ],
    };
  }

  GameConfig? _decodeConfig(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final boardSize = data['boardSize'];
    final firstPlayer = Player.values.asNameMap()[data['firstPlayer']];
    final maxCaptureSum = data['maxCaptureSum'];
    final minCaptureDice = data['minCaptureDice'];
    if (boardSize is! int ||
        firstPlayer == null ||
        maxCaptureSum is! int ||
        minCaptureDice is! int) {
      return null;
    }
    return GameConfig(
      boardSize: boardSize,
      firstPlayer: firstPlayer,
      maxCaptureSum: maxCaptureSum,
      minCaptureDice: minCaptureDice,
    );
  }

  List<Move>? _decodeMoves(Object? data) {
    if (data is! List<Object?>) return null;
    final moves = <Move>[];
    for (final item in data) {
      final move = _decodeMove(item);
      if (move == null) return null;
      moves.add(move);
    }
    return moves;
  }

  Move? _decodeMove(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final row = data['row'];
    final col = data['col'];
    final captures = _decodeSquares(data['captures']);
    if (row is! int || col is! int || captures == null) return null;
    return Move(Position(row, col), captures: captures);
  }

  Set<Position>? _decodeSquares(Object? data) {
    if (data is! List<Object?>) return null;
    final squares = <Position>{};
    for (final item in data) {
      if (item case [final int row, final int col]) {
        squares.add(Position(row, col));
      } else {
        return null;
      }
    }
    return squares;
  }
}
