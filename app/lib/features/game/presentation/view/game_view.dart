import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
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
          // Pushed on top, so the game is still here on the way back.
          IconButton(
            tooltip: 'How to play',
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.pushNamed(AppRoute.rules.name),
          ),
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.refresh),
            onPressed: () => _restart(context.read<GameBloc>()),
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
                  _headlineOf(state.game.status),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: _spacing),
                Expanded(
                  child: Center(
                    child: GameBoard(
                      state: state,
                      onSquareTapped: (square) =>
                          context.read<GameBloc>().add(SquareTapped(square)),
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

  /// Starts again under the same rules, for example on the same board size.
  static void _restart(GameBloc bloc) =>
      bloc.add(GameStarted(bloc.state.game.config));

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

  static String _headlineOf(GameStatus status) => switch (status) {
    InProgress(:final toMove) => '${playerNameOf(toMove)} to move',
    final Finished result => _resultOf(result),
  };

  /// Who won and by how much, winner first: "Player 2 wins 13 to 12".
  static String _resultOf(Finished result) {
    final (won, lost) = switch (result.winner) {
      Player.black => (result.blackDice, result.whiteDice),
      Player.white => (result.whiteDice, result.blackDice),
    };
    return '${playerNameOf(result.winner)} wins $won to $lost';
  }
}
