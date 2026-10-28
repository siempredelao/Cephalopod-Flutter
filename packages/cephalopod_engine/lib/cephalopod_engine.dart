/// Rules engine for Cephalopod, the dice game invented by Mark Steere in
/// 2006.
///
/// The engine is pure Dart: it never imports Flutter, performs no I/O and
/// reads no clock, so every rule can be unit-tested in milliseconds and
/// reused by the app, an AI opponent or a game server.
///
/// Data types (`Board`, `Move`, `GameState`…) hold data only. The rules live
/// in stateless services: start with `CephalopodRules.newGame`, ask
/// `CephalopodRules.legalMoves` what can be played, and play a `Move` with
/// `CephalopodRules.apply`.
///
/// Rule sheet: https://www.marksteeregames.com/Cephalopod_rules.pdf
library;

export 'src/models/board.dart';
export 'src/models/die.dart';
export 'src/models/game_config.dart';
export 'src/models/game_record.dart';
export 'src/models/game_state.dart';
export 'src/models/game_status.dart';
export 'src/models/move.dart';
export 'src/models/player.dart';
export 'src/models/position.dart';
export 'src/result.dart';
export 'src/rules/board_geometry.dart';
export 'src/rules/capture_finder.dart';
export 'src/rules/cephalopod_rules.dart';
export 'src/rules/illegal_move.dart';
export 'src/rules/move_validator.dart';
export 'src/rules/referee.dart';
export 'src/rules/replay_failure.dart';
