import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The effects that go with the game screen ([child]) as a whole, following
/// the `GameBloc` above it: confetti over the whole screen, app bar
/// included, when the move just played won the game for the player.
///
/// The confetti lets every tap through, so the screen works while it falls.
/// Screen readers hear the win from the headline, so it adds nothing for
/// them.
class GameEffects extends StatelessWidget {
  const GameEffects({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: BlocSelector<GameBloc, GameViewState, bool>(
            selector: (state) => state.playedMove?.celebrate ?? false,
            builder: (context, celebrate) => Confetti(play: celebrate),
          ),
        ),
      ],
    );
  }
}
