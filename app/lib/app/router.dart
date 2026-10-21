import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:cephalopod/features/game/presentation/view/game_page.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/how_to_play_page.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:go_router/go_router.dart';

/// Builds the app's router. Routes are nested, so a deep link to `/about`
/// still has the home page underneath it and a working back button.
///
/// Every game on the game route is played under [rules].
GoRouter createRouter({
  required CephalopodRules rules,
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (_, _) => const HomePage(),
        routes: [
          GoRoute(
            path: 'game',
            name: AppRoute.game.name,
            builder: (_, _) => GamePage(rules: rules),
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
