/// Rules engine for Cephalopod, the dice game invented by Mark Steere in
/// 2006.
///
/// The engine is pure Dart: it never imports Flutter, performs no I/O and
/// reads no clock, so every rule can be unit-tested in milliseconds and
/// reused by the app, an AI opponent or a game server.
///
/// Data types (`Board`, `Move`, `GameState`…) hold data only; the rules
/// live in stateless services.
///
/// Rule sheet: https://www.marksteeregames.com/Cephalopod_rules.pdf
library;

export 'src/model/board.dart';
export 'src/model/die.dart';
export 'src/model/game_config.dart';
export 'src/model/game_state.dart';
export 'src/model/game_status.dart';
export 'src/model/move.dart';
export 'src/model/player.dart';
export 'src/model/position.dart';
export 'src/rules/board_geometry.dart';
export 'src/rules/capture_finder.dart';
export 'src/rules/referee.dart';
