import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen's app bar: the title, undo and redo, How to play, and a
/// new game. Its buttons add events to the `GameBloc` above it.
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.appTitle),
      actions: [
        const _HistoryButtons(),
        // Pushed on top, so the game is still here on the way back.
        IconButton(
          tooltip: context.l10n.gameHowToPlayTooltip,
          icon: const Icon(Icons.help_outline),
          onPressed: () => context.pushNamed(AppRoute.howToPlay.name),
        ),
        IconButton(
          tooltip: context.l10n.gameRestartTooltip,
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<GameBloc>().add(const GameRestarted()),
        ),
      ],
    );
  }
}

/// Undo and redo, each enabled when there is a move to take back or to play
/// again.
class _HistoryButtons extends StatelessWidget {
  const _HistoryButtons();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();
    // Rebuilds only when undo or redo becomes available or not, not on every
    // tap on the board.
    return BlocSelector<GameBloc, GameViewState, ({bool undo, bool redo})>(
      selector: (state) => (undo: state.canUndo, redo: state.canRedo),
      builder: (context, can) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: context.l10n.gameUndoTooltip,
            icon: const Icon(Icons.undo),
            onPressed: can.undo ? () => bloc.add(const UndoRequested()) : null,
          ),
          IconButton(
            tooltip: context.l10n.gameRedoTooltip,
            icon: const Icon(Icons.redo),
            onPressed: can.redo ? () => bloc.add(const RedoRequested()) : null,
          ),
        ],
      ),
    );
  }
}
