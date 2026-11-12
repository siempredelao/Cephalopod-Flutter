import 'package:cephalopod/core/navigation/app_route.dart';
import 'package:cephalopod/core/navigation/feature_module.dart';
import 'package:cephalopod/features/settings/domain/settings_repository.dart';
import 'package:cephalopod/features/settings/domain/settings_store.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:cephalopod/features/settings/presentation/view/settings_page.dart';
import 'package:go_router/go_router.dart';

/// Wires the settings feature on the repository the composition root picks.
///
/// Its [store] lives as long as the app: the `App` widget's theme follows
/// it, the game reads it, and each visit to the settings page gets its own
/// `SettingsCubit` that changes it.
final class SettingsModule implements FeatureModule {
  SettingsModule({required this._settingsRepository});

  final SettingsRepository _settingsRepository;

  /// The player's settings for the whole app. It starts with the defaults;
  /// call `load` on it to swap in the saved ones.
  late final SettingsStore store = SettingsStore(
    settingsRepository: _settingsRepository,
  );

  /// Whether the board should mark the last move, as the settings say now.
  /// A plain function, so the composition root can hand it to features that
  /// may not import this one.
  bool highlightLastMove() => store.current.highlightLastMove;

  /// Whether the game should play its sounds, as the settings say now. A
  /// plain function, for the same reason as [highlightLastMove].
  bool soundOn() => store.current.sound;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: 'settings',
      name: AppRoute.settings.name,
      builder: (_, _) => SettingsPage(createCubit: _createCubit),
    ),
  ];

  SettingsCubit _createCubit() => SettingsCubit(settingsStore: store);
}
