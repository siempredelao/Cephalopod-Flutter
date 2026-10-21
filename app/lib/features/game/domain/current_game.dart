import 'package:cephalopod_engine/cephalopod_engine.dart';

/// The game being played: its `record`, which is what gets saved, and the
/// `state` the record's moves reach.
///
/// A Dart record, so it is plain data with value equality.
typedef CurrentGame = ({GameRecord record, GameState state});
