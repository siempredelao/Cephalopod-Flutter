import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_event.dart';
import 'package:cephalopod/features/game/presentation/models/game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/capture_controls.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/dice_tally.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_app_bar.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_headline.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The game screen: whose turn it is, how many dice each side has, the
/// board, and the controls for choosing a capture. It draws the
/// [GameViewState] of the `GameBloc` above it and adds events; the bloc
/// decides what they do.
///
/// It only lays the screen out. Each part is a widget of its own in
/// `widgets/`.
class GameView extends StatelessWidget {
  const GameView({super.key});

  static const double _spacing = 16;

  /// Room kept for [CaptureControls] even when they are hidden, so the board
  /// does not jump when they appear.
  static const double _controlsHeight = 96;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_spacing),
          child: BlocBuilder<GameBloc, GameViewState>(
            builder: (context, state) => Column(
              children: [
                GameHeadline(
                  headline: state.headline,
                  computerMove: state.playedMove?.computer,
                ),
                const SizedBox(height: _spacing / 2),
                DiceTally(tally: state.tally),
                const SizedBox(height: _spacing),
                Expanded(
                  child: Center(
                    child: GameBoard(
                      board: state.board,
                      animateDice: state.playedMove != null,
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
      capture: capture,
      onConfirm: () => bloc.add(const CaptureConfirmed()),
      onCancel: () => bloc.add(const CaptureCancelled()),
    );
  }
}
