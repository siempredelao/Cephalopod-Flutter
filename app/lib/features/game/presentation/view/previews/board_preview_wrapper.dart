import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Wraps a previewed board widget in what it needs to render: the app's
/// translations in English, which a square's screen reader label reads, a
/// theme that carries [BoardColors], which board widgets read, and a
/// Material surface.
///
/// Public and top-level because `@Preview(wrapper: …)` only accepts constant
/// tear-offs.
Widget boardPreviewWrapper(Widget child) {
  return Localizations(
    locale: const Locale('en'),
    delegates: appLocalizationsDelegates,
    child: Theme(
      data: ThemeData(extensions: const [BoardColors.light]),
      child: Material(child: child),
    ),
  );
}
