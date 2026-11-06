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
/// at a difficulty, with the person moving first or second. Start opens the
/// game on top, so coming back from it offers another.
class NewGamePage extends StatelessWidget {
  const NewGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewGameCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('New game')),
        body: BlocBuilder<NewGameCubit, NewGameChoices>(
          builder: (context, choices) => ListView(
            padding: const EdgeInsets.all(_spacing),
            children: [
              _OpponentChoice(choices),
              if (choices.againstComputer) _ComputerChoices(choices),
              FilledButton(
                onPressed: () => _start(context),
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _start(BuildContext context) async {
    final opponent = context.read<NewGameCubit>().opponent;
    await context.pushNamed(
      AppRoute.game.name,
      queryParameters: const OpponentQueryCodec().encode(opponent),
    );
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

/// How strongly the computer plays, and whether the person moves first.
class _ComputerChoices extends StatelessWidget {
  const _ComputerChoices(this.choices);

  final NewGameChoices choices;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewGameCubit>();
    final computer = choices.computer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: 'Difficulty',
          child: SegmentedButton<Difficulty>(
            segments: const [
              ButtonSegment(value: Difficulty.easy, label: Text('Easy')),
              ButtonSegment(value: Difficulty.medium, label: Text('Medium')),
              ButtonSegment(value: Difficulty.hard, label: Text('Hard')),
            ],
            selected: {computer.difficulty},
            onSelectionChanged: (choice) =>
                cubit.chooseDifficulty(choice.single),
          ),
        ),
        _Section(
          title: 'You move',
          // Each value is the colour the computer plays: when the person
          // moves first, the computer plays White, which moves second.
          child: SegmentedButton<Player>(
            segments: const [
              ButtonSegment(value: Player.white, label: Text('First')),
              ButtonSegment(value: Player.black, label: Text('Second')),
            ],
            selected: {computer.player},
            onSelectionChanged: (choice) =>
                cubit.chooseComputerPlayer(choice.single),
          ),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: _spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: _spacing),
          child,
        ],
      ),
    );
  }
}
