import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/settings_store.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_view_state_mapper.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';

/// The settings page's view model. It shows the [SettingsStore]'s settings
/// as a [SettingsViewState] (docs/adr/0015), follows them as they change,
/// and changes them through the store, which saves them.
///
/// Each visit to the page gets its own; the store outlives them all.
class SettingsCubit extends Cubit<SettingsViewState> {
  SettingsCubit({
    required this._settingsStore,
    this._settingsViewStateMapper = const SettingsViewStateMapper(),
  }) : super(_settingsViewStateMapper.map(_settingsStore.current)) {
    _subscription = _settingsStore.changes.listen(
      (settings) => emit(_settingsViewStateMapper.map(settings)),
    );
  }

  final SettingsStore _settingsStore;
  final SettingsViewStateMapper _settingsViewStateMapper;
  late final StreamSubscription<AppSettings> _subscription;

  Future<void> chooseTheme(ThemeUi theme) {
    final current = _settingsStore.current;
    return _settingsStore.update((
      theme: _settingsViewStateMapper.themePreferenceOf(theme),
      highlightLastMove: current.highlightLastMove,
      sound: current.sound,
    ));
  }

  Future<void> toggleLastMoveHighlight() {
    final current = _settingsStore.current;
    return _settingsStore.update((
      theme: current.theme,
      highlightLastMove: !current.highlightLastMove,
      sound: current.sound,
    ));
  }

  /// Stops following the store and closes, both at once: a cancelled
  /// subscription gets no more changes, whenever its cleanup ends.
  @override
  Future<void> close() async {
    await Future.wait([_subscription.cancel(), super.close()]);
  }
}
