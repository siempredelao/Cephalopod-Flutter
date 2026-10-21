import 'package:cephalopod/core/theme/board_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Wraps a previewed board widget in what it needs to render: a theme that
/// carries [BoardColors], which board widgets read, and a Material surface.
///
/// Public and top-level because `@Preview(wrapper: …)` only accepts constant
/// tear-offs.
Widget boardPreviewWrapper(Widget child) {
  return Theme(
    data: ThemeData(extensions: const [BoardColors.light]),
    child: Material(child: child),
  );
}
