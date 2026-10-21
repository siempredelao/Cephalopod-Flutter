import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Light and dark Material 3 themes generated from one seed colour.
///
/// Board and die colours live in the [BoardColors] extension, so no widget
/// hard-codes a colour.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF00897B);

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
      extensions: [
        switch (brightness) {
          Brightness.light => BoardColors.light,
          Brightness.dark => BoardColors.dark,
        },
      ],
    );
  }
}
