import 'package:material_ui/material_ui.dart';

/// A route's page shown as a dialog over the page below it, so a dialog can
/// be opened by route name like any screen, and popped with a result of type
/// [T].
class DialogPage<T> extends Page<T> {
  const DialogPage({required this.builder, super.key});

  /// Builds the dialog.
  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(context: context, settings: this, builder: builder);
  }
}
