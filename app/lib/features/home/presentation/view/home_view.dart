import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Start screen: continue the saved game, start a new one, learn how to
/// play, change the settings, or read about the game. It renders the
/// `HomeCubit` above it.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  /// Picks up the saved game, and asks the cubit again whether there is one
  /// to continue once the player is back.
  Future<void> _continue(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    await context.pushNamed(
      AppRoute.game.name,
      queryParameters: {'resume': 'true'},
    );
    await cubit.refresh();
  }

  /// Asks who to play in the new-game dialog, opens the game it closes with,
  /// and asks the cubit again once the player is back. A cancelled dialog
  /// opens nothing.
  ///
  /// The dialog gives back the game's location, so Home opens it without
  /// knowing the game feature.
  Future<void> _newGame(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    final router = GoRouter.of(context);
    final game = await router.pushNamed<String>(AppRoute.newGame.name);
    if (game == null) return;
    await router.push<void>(game);
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<HomeCubit, bool>(
              builder: (context, canContinue) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Cephalopod', style: textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'A two-player dice game on a 5×5 board.',
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (canContinue) ...[
                    FilledButton(
                      onPressed: () => _continue(context),
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => _newGame(context),
                      child: const Text('New game'),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () => _newGame(context),
                      child: const Text('New game'),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.goNamed(AppRoute.howToPlay.name),
                    child: const Text('How to play'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.goNamed(AppRoute.settings.name),
                    child: const Text('Settings'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.goNamed(AppRoute.about.name),
                    child: const Text('About'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
