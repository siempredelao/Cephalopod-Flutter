import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:go_router/go_router.dart';

/// Builds the app's router. Routes are nested, so a deep link to `/about`
/// still has the home page underneath it and a working back button.
GoRouter createRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (_, _) => const HomePage(),
        routes: [
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
