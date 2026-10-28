import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the home feature. Home is the app's root route, so unlike a
/// `FeatureModule` it takes the other features' routes as its children.
final class HomeModule {
  /// `hasGameToContinue` is a plain function rather than the game feature's
  /// use case, because features may not import each other. The composition
  /// root wires it to the game module.
  HomeModule({required this._hasGameToContinue});

  final Future<bool> Function() _hasGameToContinue;

  /// Home's route at `/`, with [children] nested under it, so a deep link
  /// to any of them still has the home page underneath and a working back
  /// button.
  GoRoute route({required List<RouteBase> children}) {
    return GoRoute(
      path: '/',
      name: AppRoute.home.name,
      builder: (_, _) => HomePage(createCubit: _createCubit),
      routes: children,
    );
  }

  HomeCubit _createCubit() {
    return HomeCubit(hasGameToContinue: _hasGameToContinue);
  }
}
