import 'package:bloc/bloc.dart';
import 'package:cephalopod/core/settings/models/app_settings.dart';
import 'package:cephalopod/core/settings/models/theme_preference.dart';
import 'package:cephalopod/core/settings/settings_repository.dart';

/// The player's settings, for the whole app: the settings screen changes
/// them, the app's theme and the game board follow them.
///
/// Starts with [defaultSettings]; [load] swaps in the saved ones. Every
/// change is saved as it is made.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit({required this._repository}) : super(defaultSettings);

  final SettingsRepository _repository;

  Future<void> load() async => emit(await _repository.load());

  Future<void> chooseTheme(ThemePreference theme) {
    return _change((theme: theme, highlightLastMove: state.highlightLastMove));
  }

  Future<void> toggleLastMoveHighlight() {
    final highlight = !state.highlightLastMove;
    return _change((theme: state.theme, highlightLastMove: highlight));
  }

  Future<void> _change(AppSettings settings) async {
    emit(settings);
    await _repository.save(settings);
  }
}
