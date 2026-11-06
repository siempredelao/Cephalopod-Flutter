import 'dart:convert';

import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Turns a [SavedGame] into the saved JSON format, and back: the move log
/// of docs/adr/0003, plus the opponent.
///
/// ```json
/// {
///   "schemaVersion": 2,
///   "config": {"boardSize": 5, "firstPlayer": "black", …},
///   "opponent": {"type": "computer", "difficulty": "hard", "player": "white"},
///   "moves": [{"row": 0, "col": 1, "captures": [[0, 0], [0, 2]]}]
/// }
/// ```
///
/// A friend is `{"type": "friend"}`. Saves from version 1, written before
/// the computer opponent existed, have no `opponent` and are read as games
/// against a friend.
///
/// Reading never throws: anything malformed gives `null`, so a corrupted
/// save starts a fresh game instead of crashing the app. Whether the moves
/// are legal is for `CephalopodRules.replay` to decide.
final class SavedGameJsonCodec {
  /// The format version written into every save. Saves with this version or
  /// [_versionWithoutOpponent] are read; any other is not.
  static const int schemaVersion = 2;

  /// The version from before saves had an opponent.
  static const int _versionWithoutOpponent = 1;

  String encode(SavedGame savedGame) {
    final config = savedGame.record.config;
    final json = {
      'schemaVersion': schemaVersion,
      'config': {
        'boardSize': config.boardSize,
        'firstPlayer': config.firstPlayer.name,
        'maxCaptureSum': config.maxCaptureSum,
        'minCaptureDice': config.minCaptureDice,
      },
      'opponent': _encodeOpponent(savedGame.opponent),
      'moves': [for (final move in savedGame.record.moves) _encodeMove(move)],
    };
    return jsonEncode(json);
  }

  /// The game in [json], or `null` when it is not a save this version can
  /// read.
  SavedGame? decode(String json) {
    final Object? data;
    try {
      data = jsonDecode(json);
    } on FormatException {
      return null;
    }
    if (data is! Map<String, Object?>) return null;
    final opponent = switch (data['schemaVersion']) {
      _versionWithoutOpponent => const FriendOpponent(),
      schemaVersion => _decodeOpponent(data['opponent']),
      _ => null,
    };
    final config = _decodeConfig(data['config']);
    final moves = _decodeMoves(data['moves']);
    if (opponent == null || config == null || moves == null) return null;
    final record = GameRecord(config: config, moves: moves);
    return (record: record, opponent: opponent);
  }

  Map<String, Object?> _encodeOpponent(Opponent opponent) {
    return switch (opponent) {
      FriendOpponent() => {'type': 'friend'},
      ComputerOpponent(:final difficulty, :final player) => {
        'type': 'computer',
        'difficulty': difficulty.name,
        'player': player.name,
      },
    };
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

  Opponent? _decodeOpponent(Object? data) {
    if (data is! Map<String, Object?>) return null;
    return switch (data['type']) {
      'friend' => const FriendOpponent(),
      'computer' => _decodeComputer(data),
      _ => null,
    };
  }

  ComputerOpponent? _decodeComputer(Map<String, Object?> data) {
    final difficulty = Difficulty.values.asNameMap()[data['difficulty']];
    final player = Player.values.asNameMap()[data['player']];
    if (difficulty == null || player == null) return null;
    return ComputerOpponent(difficulty: difficulty, player: player);
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
