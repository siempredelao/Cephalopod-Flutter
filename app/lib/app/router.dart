import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/home/home_module.dart';
import 'package:go_router/go_router.dart';

/// Builds the app's router. Home is the root route and every other
/// feature's routes are nested under it, so a deep link to `/about` still
/// has the home page underneath it and a working back button.
///
/// Each feature brings its own routes through its [FeatureModule], so a new
/// feature is one more entry in [features], not a change to this function.
GoRouter createRouter({
  required HomeModule home,
  required List<FeatureModule> features,
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      home.route(
        children: [for (final feature in features) ...feature.routes],
      ),
    ],
  );
}
