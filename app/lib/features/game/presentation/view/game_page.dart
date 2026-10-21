import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/view/game_view.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen's entry point: starts a new game under [rules] and hands
/// its `GameBloc` to [GameView].
class GamePage extends StatelessWidget {
  const GamePage({required this.rules, super.key});

  final CephalopodRules rules;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(rules: rules),
      child: const GameView(),
    );
  }
}
