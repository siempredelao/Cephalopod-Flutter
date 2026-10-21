import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:cephalopod/features/game/presentation/bloc/game_bloc.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/how_to_play_page.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:go_router/go_router.dart';

/// Builds the app's router. Routes are nested, so a deep link to `/about`
/// still has the home page underneath it and a working back button.
///
/// Each visit to the game route gets its own bloc from [createGameBloc]. The
/// route starts a new game, or picks up the saved one with `?resume=true`.
/// Home offers that when [hasGameToContinue] says there is one.
GoRouter createRouter({
  required GameBloc Function() createGameBloc,
  required Future<bool> Function() hasGameToContinue,
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (_, _) => HomePage(hasGameToContinue: hasGameToContinue),
        routes: [
          GoRoute(
            path: 'game',
            name: AppRoute.game.name,
            builder: (_, state) => GamePage(
              createBloc: createGameBloc,
              resume: state.uri.queryParameters['resume'] == 'true',
            ),
          ),
          GoRoute(
            path: 'how-to-play',
            name: AppRoute.howToPlay.name,
            builder: (_, _) => const HowToPlayPage(),
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
