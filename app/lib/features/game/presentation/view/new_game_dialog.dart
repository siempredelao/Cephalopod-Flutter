import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_cubit.dart';
import 'package:cephalopod/features/game/presentation/models/difficulty_ui.dart';
import 'package:cephalopod/features/game/presentation/models/new_game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/opponent_ui.dart';
import 'package:cephalopod/features/game/presentation/models/person_moves_ui.dart';
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
      child: BlocBuilder<NewGameCubit, NewGameViewState>(
        builder: (context, state) => AlertDialog(
          title: Text(context.l10n.newGameTitle),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OpponentChoice(state.opponent),
              if (state.opponent case final ComputerOpponentUi computer) ...[
                const SizedBox(height: _spacing),
                _DifficultyChoice(computer.difficulty),
                const SizedBox(height: _spacing),
                _PersonMovesChoice(computer.personMoves),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _cancel(context),
              child: Text(context.l10n.newGameCancel),
            ),
            FilledButton(
              onPressed: () => _start(context),
              child: Text(context.l10n.newGameStart),
            ),
          ],
        ),
      ),
    );
  }

  static void _cancel(BuildContext context) => context.pop();

  static void _start(BuildContext context) {
    final game = context.namedLocation(
      AppRoute.game.name,
      queryParameters: context.read<NewGameCubit>().gameQueryParameters,
    );
    context.pop(game);
  }
}

/// The segments of the opponent choice. A segment needs a plain value to
/// compare, and the computer's [OpponentUi] carries its choices, so the
/// segments have their own.
enum _OpponentSegment { friend, computer }

/// A friend, or the computer, with the [opponent] chosen.
class _OpponentChoice extends StatelessWidget {
  const _OpponentChoice(this.opponent);

  final OpponentUi opponent;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewGameCubit>();
    return _Section(
      title: context.l10n.newGameOpponent,
      child: SegmentedButton<_OpponentSegment>(
        segments: [
          ButtonSegment(
            value: _OpponentSegment.friend,
            label: Text(context.l10n.newGameFriend),
          ),
          ButtonSegment(
            value: _OpponentSegment.computer,
            label: Text(context.l10n.newGameComputer),
          ),
        ],
        selected: {_segmentOf(opponent)},
        onSelectionChanged: (choice) {
          switch (choice.single) {
            case _OpponentSegment.friend:
              cubit.chooseFriend();
            case _OpponentSegment.computer:
              cubit.chooseComputer();
          }
        },
      ),
    );
  }

  static _OpponentSegment _segmentOf(OpponentUi opponent) {
    return switch (opponent) {
      FriendOpponentUi() => _OpponentSegment.friend,
      ComputerOpponentUi() => _OpponentSegment.computer,
    };
  }
}

/// How strongly the computer plays, with the [difficulty] chosen.
class _DifficultyChoice extends StatelessWidget {
  const _DifficultyChoice(this.difficulty);

  final DifficultyUi difficulty;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewGameCubit>();
    return _Section(
      title: context.l10n.newGameDifficulty,
      child: SegmentedButton<DifficultyUi>(
        segments: [
          ButtonSegment(
            value: DifficultyUi.easy,
            label: Text(context.l10n.newGameEasy),
          ),
          ButtonSegment(
            value: DifficultyUi.medium,
            label: Text(context.l10n.newGameMedium),
          ),
          ButtonSegment(
            value: DifficultyUi.hard,
            label: Text(context.l10n.newGameHard),
          ),
        ],
        selected: {difficulty},
        onSelectionChanged: (choice) => cubit.chooseDifficulty(choice.single),
      ),
    );
  }
}

/// Whether the person moves first or second, with [personMoves] chosen.
class _PersonMovesChoice extends StatelessWidget {
  const _PersonMovesChoice(this.personMoves);

  final PersonMovesUi personMoves;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewGameCubit>();
    return _Section(
      title: context.l10n.newGamePersonMoves,
      child: SegmentedButton<PersonMovesUi>(
        segments: [
          ButtonSegment(
            value: PersonMovesUi.first,
            label: Text(context.l10n.newGameFirst),
          ),
          ButtonSegment(
            value: PersonMovesUi.second,
            label: Text(context.l10n.newGameSecond),
          ),
        ],
        selected: {personMoves},
        onSelectionChanged: (choice) => cubit.choosePersonMoves(choice.single),
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
