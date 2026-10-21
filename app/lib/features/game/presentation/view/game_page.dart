import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/view/game_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen's entry point: gets a `GameBloc` from [createBloc], starts
/// a new game or, with [resume], picks up the saved one, and hands the bloc
/// to [GameView].
class GamePage extends StatelessWidget {
  const GamePage({required this.createBloc, this.resume = false, super.key});

  /// Builds the screen's bloc. The composition root wires it to the device's
  /// storage; tests wire it to memory.
  final GameBloc Function() createBloc;
  final bool resume;

  GameEvent get _opening => resume ? const GameResumed() : const GameStarted();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc()..add(_opening),
      child: const GameView(),
    );
  }
}
