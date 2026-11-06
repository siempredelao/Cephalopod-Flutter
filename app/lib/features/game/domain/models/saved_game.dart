import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A game as the app saves it: the engine's `record`, which holds the config
/// and the moves played (docs/adr/0003), and the `opponent` the person
/// faces.
///
/// A Dart record, so it is plain data with value equality.
typedef SavedGame = ({GameRecord record, Opponent opponent});
