import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_name.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_controls.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen: whose turn it is, the board, and the controls for
/// choosing a capture. It draws the [GameViewState] of the `GameBloc` above
/// it and adds events; the bloc decides what they do.
class GameView extends StatelessWidget {
  const GameView({super.key});

  static const double _spacing = 16;

  /// Room kept for [CaptureControls] even when they are hidden, so the board
  /// does not jump when they appear.
  static const double _controlsHeight = 96;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cephalopod'),
        actions: [
          const _HistoryButtons(),
          // Pushed on top, so the game is still here on the way back.
          IconButton(
            tooltip: 'How to play',
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.pushNamed(AppRoute.howToPlay.name),
          ),
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<GameBloc>().add(const GameRestarted()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_spacing),
          child: BlocBuilder<GameBloc, GameViewState>(
            builder: (context, state) => Column(
              children: [
                Text(
                  _headlineOf(state.headline),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: _spacing),
                Expanded(
                  child: Center(
                    child: GameBoard(
                      board: state.board,
                      onSquareTapped: _tapHandlerOf(context, state),
                    ),
                  ),
                ),
                const SizedBox(height: _spacing),
                SizedBox(
                  height: _controlsHeight,
                  child: _controlsFor(context, state),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// What a tap on a square does: nothing when the board takes no taps,
  /// such as while the computer thinks, because a tap sent then would wait,
  /// and land after the computer's move.
  static ValueChanged<SquareUi>? _tapHandlerOf(
    BuildContext context,
    GameViewState state,
  ) {
    if (!state.canTap) return null;
    final bloc = context.read<GameBloc>();
    return (square) => bloc.add(SquareTapped(row: square.row, col: square.col));
  }

  static Widget? _controlsFor(BuildContext context, GameViewState state) {
    final capture = state.capture;
    if (capture == null) return null;
    final bloc = context.read<GameBloc>();
    return CaptureControls(
      selectedSum: capture.selectedSum,
      maxSum: capture.maxSum,
      canConfirm: capture.canConfirm,
      onConfirm: () => bloc.add(const CaptureConfirmed()),
      onCancel: () => bloc.add(const CaptureCancelled()),
    );
  }

  /// What the game waits for, or how it ended, winner first: "Player 2 wins
  /// 13 to 12". Against the computer, the person is "you".
  static String _headlineOf(HeadlineUi headline) => switch (headline) {
    PlayerToMoveHeadline(:final player) => '${playerUiNameOf(player)} to move',
    PersonToMoveHeadline() => 'Your turn',
    ComputerToMoveHeadline() => 'The computer is thinking…',
    PlayerWonHeadline(:final player, :final winnerDice, :final loserDice) =>
      '${playerUiNameOf(player)} wins $winnerDice to $loserDice',
    PersonWonHeadline(:final winnerDice, :final loserDice) =>
      'You win $winnerDice to $loserDice',
    ComputerWonHeadline(:final winnerDice, :final loserDice) =>
      'The computer wins $winnerDice to $loserDice',
  };
}

/// Undo and redo, each enabled when there is a move to take back or to play
/// again.
class _HistoryButtons extends StatelessWidget {
  const _HistoryButtons();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();
    return BlocBuilder<GameBloc, GameViewState>(
      builder: (context, state) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: state.canUndo
                ? () => bloc.add(const UndoRequested())
                : null,
          ),
          IconButton(
            tooltip: 'Redo',
            icon: const Icon(Icons.redo),
            onPressed: state.canRedo
                ? () => bloc.add(const RedoRequested())
                : null,
          ),
        ],
      ),
    );
  }
}
