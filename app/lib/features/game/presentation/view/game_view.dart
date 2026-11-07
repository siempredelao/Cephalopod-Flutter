import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/board_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_name.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_controls.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen: whose turn it is, the board, and the controls for
/// choosing a capture. It renders the state of the `GameBloc` above it and
/// adds events; the bloc decides what they do.
class GameView extends StatelessWidget {
  const GameView({this.highlightLastMove = true, super.key});

  /// Whether the board marks the last move.
  final bool highlightLastMove;

  static const double _spacing = 16;

  // Until the bloc's state carries the board, the view maps it on each build.
  static const BoardUiMapper _boardUiMapper = BoardUiMapper();

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
                  _headlineOf(state),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: _spacing),
                Expanded(
                  child: Center(
                    child: GameBoard(
                      board: _boardOf(state),
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

  BoardUi _boardOf(GameViewState state) {
    return _boardUiMapper.map(
      game: state.game,
      phase: state.phase,
      lastMove: state.lastMove,
      opponent: state.opponent,
      highlightLastMove: highlightLastMove,
    );
  }

  /// What a tap on a square does: nothing while the computer thinks, because
  /// a tap sent then would wait, and land after the computer's move.
  static ValueChanged<SquareUi>? _tapHandlerOf(
    BuildContext context,
    GameViewState state,
  ) {
    if (state.phase is ComputerThinking) return null;
    final bloc = context.read<GameBloc>();
    return (square) => bloc.add(SquareTapped(row: square.row, col: square.col));
  }

  static Widget? _controlsFor(BuildContext context, GameViewState state) {
    final phase = state.phase;
    if (phase is! ChoosingCapture) return null;
    final bloc = context.read<GameBloc>();
    return CaptureControls(
      selectedSum: phase.selectedSum,
      maxSum: state.game.config.maxCaptureSum,
      canConfirm: phase.canConfirm,
      onConfirm: () => bloc.add(const CaptureConfirmed()),
      onCancel: () => bloc.add(const CaptureCancelled()),
    );
  }

  /// What the game waits for, or how it ended. Against the computer, the
  /// person is "you".
  static String _headlineOf(GameViewState state) {
    if (state.phase is ComputerThinking) return 'The computer is thinking…';
    return switch ((state.game.status, state.opponent)) {
      (InProgress(), ComputerOpponent()) => 'Your turn',
      (InProgress(:final toMove), FriendOpponent()) =>
        '${playerNameOf(toMove)} to move',
      (final Finished result, final opponent) => _resultOf(result, opponent),
    };
  }

  /// Who won and by how much, winner first: "Player 2 wins 13 to 12", or
  /// against the computer "You win 13 to 12".
  static String _resultOf(Finished result, Opponent opponent) {
    final (won, lost) = switch (result.winner) {
      Player.black => (result.blackDice, result.whiteDice),
      Player.white => (result.whiteDice, result.blackDice),
    };
    final winner = switch (opponent) {
      FriendOpponent() => '${playerNameOf(result.winner)} wins',
      ComputerOpponent(:final player) when player == result.winner =>
        'The computer wins',
      ComputerOpponent() => 'You win',
    };
    return '$winner $won to $lost';
  }
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
