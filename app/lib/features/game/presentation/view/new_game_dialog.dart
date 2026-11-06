import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_choices.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_cubit.dart';
import 'package:cephalopod/features/game/presentation/view/opponent_query_codec.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const double _spacing = 16;

/// Choosing who to play against: a friend on this device, or the computer
/// at a difficulty, with the person moving first or second.
///
/// Start closes the dialog with the location of the game to open, such as
/// `/game?computer=white&difficulty=hard`, so whoever opened it can open
/// the game without knowing the game feature. Cancel, or a tap outside,
/// closes it with nothing.
class NewGameDialog extends StatelessWidget {
  const NewGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewGameCubit(),
      child: BlocBuilder<NewGameCubit, NewGameChoices>(
        builder: (context, choices) => AlertDialog(
          title: const Text('New game'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OpponentChoice(choices),
              if (choices.againstComputer) ...[
                const SizedBox(height: _spacing),
                _DifficultyChoice(choices),
                const SizedBox(height: _spacing),
                _FirstMoveChoice(choices),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _cancel(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _start(context),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  static void _cancel(BuildContext context) => context.pop();

  static void _start(BuildContext context) {
    final opponent = context.read<NewGameCubit>().opponent;
    final game = context.namedLocation(
      AppRoute.game.name,
      queryParameters: const OpponentQueryCodec().encode(opponent),
    );
    context.pop(game);
  }
}

/// A friend, or the computer.
class _OpponentChoice extends StatelessWidget {
  const _OpponentChoice(this.choices);

  final NewGameChoices choices;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewGameCubit>();
    return _Section(
      title: 'Opponent',
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('A friend')),
          ButtonSegment(value: true, label: Text('The computer')),
        ],
        selected: {choices.againstComputer},
        onSelectionChanged: (choice) {
          if (choice.single) {
            cubit.chooseComputer();
          } else {
            cubit.chooseFriend();
          }
        },
      ),
    );
  }
}

/// How strongly the computer plays.
class _DifficultyChoice extends StatelessWidget {
  const _DifficultyChoice(this.choices);

  final NewGameChoices choices;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewGameCubit>();
    return _Section(
      title: 'Difficulty',
      child: SegmentedButton<Difficulty>(
        segments: const [
          ButtonSegment(value: Difficulty.easy, label: Text('Easy')),
          ButtonSegment(value: Difficulty.medium, label: Text('Medium')),
          ButtonSegment(value: Difficulty.hard, label: Text('Hard')),
        ],
        selected: {choices.computer.difficulty},
        onSelectionChanged: (choice) => cubit.chooseDifficulty(choice.single),
      ),
    );
  }
}

/// Whether the person moves first or second.
class _FirstMoveChoice extends StatelessWidget {
  const _FirstMoveChoice(this.choices);

  final NewGameChoices choices;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewGameCubit>();
    return _Section(
      title: 'You move',
      // Each value is the colour the computer plays: when the person moves
      // first, the computer plays White, which moves second.
      child: SegmentedButton<Player>(
        segments: const [
          ButtonSegment(value: Player.white, label: Text('First')),
          ButtonSegment(value: Player.black, label: Text('Second')),
        ],
        selected: {choices.computer.player},
        onSelectionChanged: (choice) =>
            cubit.chooseComputerPlayer(choice.single),
      ),
    );
  }
}

/// A [title] above the [child] that chooses it.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: _spacing / 2),
        child,
      ],
    );
  }
}
