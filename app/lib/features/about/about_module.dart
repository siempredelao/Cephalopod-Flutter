import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/about/presentation/view/about_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the about feature: a single page with no dependencies.
final class AboutModule implements FeatureModule {
  const AboutModule();

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: 'about',
      name: AppRoute.about.name,
      builder: (_, _) => const AboutPage(),
    ),
  ];
}
