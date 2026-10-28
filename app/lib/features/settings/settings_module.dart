import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/settings/domain/settings_repository.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:cephalopod/features/settings/presentation/view/settings_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the settings feature on the repository the composition root picks.
///
/// Unlike other features, its [cubit] lives as long as the app: the `App`
/// widget provides it to every screen, so the theme follows it and the
/// settings page changes it.
final class SettingsModule implements FeatureModule {
  SettingsModule({required this._repository});

  final SettingsRepository _repository;

  /// The player's settings for the whole app. It starts with the defaults;
  /// call `load` on it to swap in the saved ones.
  late final SettingsCubit cubit = SettingsCubit(repository: _repository);

  /// Whether the board should mark the last move, as the settings say now.
  /// A plain function, so the composition root can hand it to features that
  /// may not import this one.
  bool highlightLastMove() => cubit.state.highlightLastMove;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: 'settings',
      name: AppRoute.settings.name,
      // Reads the cubit the App widget provides.
      builder: (_, _) => const SettingsPage(),
    ),
  ];
}
