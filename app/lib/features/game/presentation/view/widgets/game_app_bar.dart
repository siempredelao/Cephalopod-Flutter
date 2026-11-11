import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen's app bar: the title, How to play, and a menu of the
/// game's actions. Two icons, so the title has room on a small phone.
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.appTitle),
      actions: [
        // Pushed on top, so the game is still here on the way back.
        IconButton(
          tooltip: context.l10n.gameHowToPlayTooltip,
          icon: const Icon(Icons.help_outline),
          onPressed: () => context.pushNamed(AppRoute.howToPlay.name),
        ),
        const _GameMenu(),
      ],
    );
  }
}

/// The "more" button and its menu: undo, redo and a new game. Undo and redo
/// are enabled when there is a move to take back or to play again. The menu
/// adds events to the `GameBloc` above it.
class _GameMenu extends StatelessWidget {
  const _GameMenu();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();
    final l10n = context.l10n;
    // Rebuilds only when undo or redo becomes available or not, not on every
    // tap on the board, so an open menu follows the game too.
    return BlocSelector<GameBloc, GameViewState, ({bool undo, bool redo})>(
      selector: (state) => (undo: state.canUndo, redo: state.canRedo),
      builder: (context, can) => MenuAnchor(
        menuChildren: [
          MenuItemButton(
            leadingIcon: const Icon(Icons.undo),
            onPressed: can.undo ? () => bloc.add(const UndoRequested()) : null,
            child: Text(l10n.gameMenuUndo),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.redo),
            onPressed: can.redo ? () => bloc.add(const RedoRequested()) : null,
            child: Text(l10n.gameMenuRedo),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.refresh),
            onPressed: () => bloc.add(const GameRestarted()),
            child: Text(l10n.gameMenuNewGame),
          ),
        ],
        builder: (context, menu, _) => IconButton(
          tooltip: l10n.gameMenuTooltip,
          icon: const Icon(Icons.more_vert),
          onPressed: () => menu.isOpen ? menu.close() : menu.open(),
        ),
      ),
    );
  }
}
