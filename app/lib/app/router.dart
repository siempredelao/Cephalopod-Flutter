import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/how_to_play_page.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:cephalopod/features/settings/presentation/view/settings_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Builds the app's router. Routes are nested, so a deep link to `/about`
/// still has the home page underneath it and a working back button.
///
/// Home gets its cubit from [createHomeCubit], and each visit to the game
/// route gets its own bloc from [createGameBloc]. The game route starts a
/// new game, or picks up the saved one with `?resume=true`, which Home
/// offers when there is one.
GoRouter createRouter({
  required HomeCubit Function() createHomeCubit,
  required GameBloc Function() createGameBloc,
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (_, _) => HomePage(createCubit: createHomeCubit),
        routes: [
          GoRoute(
            path: 'game',
            name: AppRoute.game.name,
            // Settings cannot change while a game is on screen, so the game
            // reads the highlight setting once, when it opens.
            builder: (context, state) {
              final settings = context.read<SettingsCubit>().state;
              return GamePage(
                createBloc: createGameBloc,
                resume: state.uri.queryParameters['resume'] == 'true',
                highlightLastMove: settings.highlightLastMove,
              );
            },
          ),
          GoRoute(
            path: 'how-to-play',
            name: AppRoute.howToPlay.name,
            builder: (_, _) => const HowToPlayPage(),
          ),
          GoRoute(
            path: 'settings',
            name: AppRoute.settings.name,
            builder: (_, _) => const SettingsPage(),
          ),
          GoRoute(
            path: 'about',
            name: AppRoute.about.name,
            builder: (_, _) => const AboutPage(),
          ),
        ],
      ),
    ],
  );
}
