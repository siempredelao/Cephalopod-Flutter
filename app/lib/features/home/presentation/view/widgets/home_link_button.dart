import 'package:material_ui/material_ui.dart';

/// A small button for a screen Home leads to, with its [icon] above its
/// [label]. The label is what screen readers say; the icon only decorates it.
class HomeLinkButton extends StatelessWidget {
  const HomeLinkButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  static const double _minHeight = 64;
  static const double _iconSize = 24;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      // Icons line up at the top, whatever the number of lines a label takes.
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(_minHeight),
        alignment: Alignment.topCenter,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(height: _gap),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
