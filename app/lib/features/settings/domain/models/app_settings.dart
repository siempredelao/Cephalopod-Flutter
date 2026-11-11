import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';

/// The player's choices that apply across the app: the `theme`, whether the
/// game board marks the last move (`highlightLastMove`), and whether the
/// game plays sounds (`sound`).
///
/// A Dart record, so it is plain data with value equality.
typedef AppSettings = ({
  ThemePreference theme,
  bool highlightLastMove,
  bool sound,
});

/// The settings before the player changes any.
const AppSettings defaultSettings = (
  theme: ThemePreference.system,
  highlightLastMove: true,
  sound: true,
);
