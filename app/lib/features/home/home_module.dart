import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/view/home_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the home feature. Home is the app's root route, so unlike a
/// `FeatureModule` it takes the other features' routes as its children.
final class HomeModule {
  /// `savedGameSummary` and `hasSeenHowToPlay` are plain functions rather
  /// than other features' own code, because features may not import each
  /// other. The composition root wires them to the game and How to play
  /// modules.
  HomeModule({
    required this._savedGameSummary,
    required this._hasSeenHowToPlay,
  });

  final Future<SavedGameSummary?> Function() _savedGameSummary;
  final Future<bool> Function() _hasSeenHowToPlay;

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
    return HomeCubit(
      savedGameSummary: _savedGameSummary,
      hasSeenHowToPlay: _hasSeenHowToPlay,
    );
  }
}
