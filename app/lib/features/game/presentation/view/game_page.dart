import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/view/game_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen's entry point: gets a `GameBloc` from [createBloc], sends
/// it [opening], and hands the bloc to [GameView].
class GamePage extends StatelessWidget {
  const GamePage({
    required this.createBloc,
    required this.opening,
    super.key,
  });

  /// Builds the screen's bloc. The composition root wires it to the device's
  /// storage; tests wire it to memory.
  final GameBloc Function() createBloc;

  /// The first event: `GameStarted` for a new game against an opponent, or
  /// `GameResumed` to pick up the saved one.
  final GameEvent opening;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc()..add(opening),
      child: const GameView(),
    );
  }
}
