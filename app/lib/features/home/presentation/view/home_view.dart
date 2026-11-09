import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/models/home_view_state.dart';
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
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<HomeCubit, HomeViewState>(
              builder: (context, state) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.appTitle, style: textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeTagline,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (state.canContinue) ...[
                    FilledButton(
                      onPressed: () => _continue(context),
                      child: Text(l10n.homeContinue),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => _newGame(context),
                      child: Text(l10n.homeNewGame),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () => _newGame(context),
                      child: Text(l10n.homeNewGame),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.goNamed(AppRoute.howToPlay.name),
                    child: Text(l10n.homeHowToPlay),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.goNamed(AppRoute.settings.name),
                    child: Text(l10n.homeSettings),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.goNamed(AppRoute.about.name),
                    child: Text(l10n.homeAbout),
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
