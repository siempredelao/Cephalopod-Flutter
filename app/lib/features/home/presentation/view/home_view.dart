import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/models/home_view_state.dart';
import 'package:cephalopod/features/home/presentation/view/widgets/demo_board.dart';
import 'package:cephalopod/features/home/presentation/view/widgets/home_link_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Start screen: continue the saved game, start a new one, learn how to
/// play, change the settings, or read about the game. It renders the
/// `HomeCubit` above it.
///
/// A small board above the title plays a capture on a loop. One big button
/// starts the game. The other screens are a row of small
/// buttons at the bottom, over a teal background that fades downwards.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const double _padding = 24;
  static const double _mainButtonHeight = 56;

  /// How far down the screen the teal has faded into the background, as a
  /// share of its height.
  static const double _gradientEnd = 0.6;

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
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final mainButtonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(_mainButtonHeight),
      textStyle: textTheme.titleMedium,
    );
    return Scaffold(
      body: DecoratedBox(
        // The theme's teal at the top, fading into the plain background.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.primaryContainer, colors.surface],
            stops: const [0, _gradientEnd],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<HomeCubit, HomeViewState>(
            // On the first launch, How to play opens over Home, so Back
            // leads here.
            listenWhen: (before, now) =>
                !before.showHowToPlay && now.showHowToPlay,
            listener: (context, _) {
              context.read<HomeCubit>().howToPlayOpened();
              context.goNamed(AppRoute.howToPlay.name);
            },
            // The page fills the screen, and scrolls only if it must: with
            // large text, or a short screen.
            builder: (context, state) => CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(_padding),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DemoBoard(
                                  demo: context.read<HomeCubit>().demo,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  l10n.appTitle,
                                  style: textTheme.displaySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.homeTagline,
                                  style: textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.canContinue) ...[
                          FilledButton(
                            style: mainButtonStyle,
                            onPressed: () => _continue(context),
                            child: Text(l10n.homeContinue),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            style: mainButtonStyle,
                            onPressed: () => _newGame(context),
                            child: Text(l10n.homeNewGame),
                          ),
                        ] else
                          FilledButton(
                            style: mainButtonStyle,
                            onPressed: () => _newGame(context),
                            child: Text(l10n.homeNewGame),
                          ),
                        const SizedBox(height: 16),
                        // As tall as the one with the most lines of text,
                        // so the buttons are alike.
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: HomeLinkButton(
                                  icon: Icons.help_outline,
                                  label: l10n.homeHowToPlay,
                                  onPressed: () =>
                                      context.goNamed(AppRoute.howToPlay.name),
                                ),
                              ),
                              Expanded(
                                child: HomeLinkButton(
                                  icon: Icons.settings_outlined,
                                  label: l10n.homeSettings,
                                  onPressed: () =>
                                      context.goNamed(AppRoute.settings.name),
                                ),
                              ),
                              Expanded(
                                child: HomeLinkButton(
                                  icon: Icons.info_outline,
                                  label: l10n.homeAbout,
                                  onPressed: () =>
                                      context.goNamed(AppRoute.about.name),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
