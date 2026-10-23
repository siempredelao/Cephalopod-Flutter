import 'package:cephalopod/core/settings/models/theme_preference.dart';

/// The player's choices that apply across the app: the `theme`, and whether
/// the game board marks the last move (`highlightLastMove`).
///
/// A Dart record, so it is plain data with value equality.
typedef AppSettings = ({ThemePreference theme, bool highlightLastMove});

/// The settings before the player changes any.
const AppSettings defaultSettings = (
  theme: ThemePreference.system,
  highlightLastMove: true,
);
