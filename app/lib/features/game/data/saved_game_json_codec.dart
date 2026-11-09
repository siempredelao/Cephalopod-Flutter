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
///   "schemaVersion": 1,
///   "config": {"boardSize": 5, "firstPlayer": "black", …},
///   "opponent": {"type": "computer", "difficulty": "hard", "player": "white"},
///   "moves": [{"row": 0, "col": 1, "captures": [[0, 0], [0, 2]]}]
/// }
/// ```
///
/// A friend is `{"type": "friend"}`.
///
/// Reading never throws: anything malformed gives `null`, so a corrupted
/// save starts a fresh game instead of crashing the app. Whether the moves
/// are legal is for `CephalopodRules.replay` to decide.
final class SavedGameJsonCodec {
  /// The format version written into every save. A save with another
  /// version is not read.
  static const int schemaVersion = 1;

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
    if (data['schemaVersion'] != schemaVersion) return null;
    final opponent = _decodeOpponent(data['opponent']);
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

  // Each map pattern below matches only a map that has every key it names,
  // each holding a value of the type it names. Anything else falls through
  // to `null`.

  Opponent? _decodeOpponent(Object? data) {
    return switch (data) {
      {'type': 'friend'} => const FriendOpponent(),
      {
        'type': 'computer',
        'difficulty': final String difficulty,
        'player': final String player,
      } =>
        _decodeComputer(difficulty, player),
      _ => null,
    };
  }

  ComputerOpponent? _decodeComputer(String difficultyName, String playerName) {
    final difficulty = Difficulty.values.asNameMap()[difficultyName];
    final player = Player.values.asNameMap()[playerName];
    if (difficulty == null || player == null) return null;
    return ComputerOpponent(difficulty: difficulty, player: player);
  }

  GameConfig? _decodeConfig(Object? data) {
    if (data case {
      'boardSize': final int boardSize,
      'firstPlayer': final String firstPlayerName,
      'maxCaptureSum': final int maxCaptureSum,
      'minCaptureDice': final int minCaptureDice,
    }) {
      final firstPlayer = Player.values.asNameMap()[firstPlayerName];
      if (firstPlayer == null) return null;
      return GameConfig(
        boardSize: boardSize,
        firstPlayer: firstPlayer,
        maxCaptureSum: maxCaptureSum,
        minCaptureDice: minCaptureDice,
      );
    }
    return null;
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
    if (data case {
      'row': final int row,
      'col': final int col,
      'captures': final Object? captureData,
    }) {
      final captures = _decodeSquares(captureData);
      if (captures == null) return null;
      return Move(Position(row, col), captures: captures);
    }
    return null;
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
