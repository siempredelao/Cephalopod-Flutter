import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Builds the engine agent that plays at a [Difficulty].
///
/// A plain function that the game module provides, so the module decides
/// which agent plays each level (docs/adr/0014). A new or stronger agent
/// changes that wiring, not the use cases.
typedef AgentFactory = GameAgent Function(Difficulty difficulty);
