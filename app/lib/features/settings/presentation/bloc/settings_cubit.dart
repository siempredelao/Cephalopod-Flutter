import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/domain/settings_repository.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_view_state_mapper.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';

/// The player's settings, for the whole app: the settings screen changes
/// them, the app's theme and the game board follow them.
///
/// It keeps the [settings] themselves and emits them as a
/// [SettingsViewState] (docs/adr/0015). It starts with [defaultSettings];
/// [load] swaps in the saved ones. Every change is saved as it is made.
class SettingsCubit extends Cubit<SettingsViewState> {
  SettingsCubit({
    required this._settingsRepository,
    this._settingsViewStateMapper = const SettingsViewStateMapper(),
  }) : super(_settingsViewStateMapper.map(defaultSettings));

  final SettingsRepository _settingsRepository;
  final SettingsViewStateMapper _settingsViewStateMapper;

  AppSettings _settings = defaultSettings;

  /// The settings as the rest of the app reads them, such as whether the
  /// game board marks the last move. Screens read [state] instead.
  AppSettings get settings => _settings;

  Future<void> load() async => _show(await _settingsRepository.load());

  Future<void> chooseTheme(ThemeUi theme) {
    final changed = (
      theme: _themePreferenceOf(theme),
      highlightLastMove: _settings.highlightLastMove,
    );
    return _change(changed);
  }

  Future<void> toggleLastMoveHighlight() {
    final highlight = !_settings.highlightLastMove;
    return _change((theme: _settings.theme, highlightLastMove: highlight));
  }

  Future<void> _change(AppSettings settings) async {
    _show(settings);
    await _settingsRepository.save(settings);
  }

  void _show(AppSettings settings) {
    _settings = settings;
    emit(_settingsViewStateMapper.map(settings));
  }

  static ThemePreference _themePreferenceOf(ThemeUi theme) => switch (theme) {
    ThemeUi.system => ThemePreference.system,
    ThemeUi.light => ThemePreference.light,
    ThemeUi.dark => ThemePreference.dark,
  };
}
