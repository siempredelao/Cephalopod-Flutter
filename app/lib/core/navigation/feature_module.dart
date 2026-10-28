import 'package:go_router/go_router.dart';

/// A feature's own wiring. A module builds the feature's objects from the
/// shared dependencies the composition root hands it, and exposes the
/// routes that show them, so the router never imports a feature's pages.
///
/// The router mounts [routes] under home, so their paths are relative:
/// `game`, not `/game`.
abstract interface class FeatureModule {
  /// The feature's routes, each building its page with the feature's
  /// dependencies.
  List<RouteBase> get routes;
}
