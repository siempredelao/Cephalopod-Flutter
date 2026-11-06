import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Builds the engine agent that plays at a [Difficulty].
///
/// A plain function that the game module provides, so the module decides
/// which agent plays each level (docs/adr/0014). A new or stronger agent
/// changes that wiring, not the use cases.
///
/// Called for every computer move, and the agent then runs on a copy in
/// another isolate: an agent kept between moves would keep its `Random` as
/// it was, and repeat the same random choices. Build a new one each time.
typedef AgentFactory = GameAgent Function(Difficulty difficulty);
