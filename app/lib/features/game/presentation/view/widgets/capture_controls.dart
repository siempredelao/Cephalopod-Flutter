import 'package:material_ui/material_ui.dart';

/// Shown while the player chooses a capture: the pip sum of the dice picked
/// so far, a button to capture them and one to back out.
class CaptureControls extends StatelessWidget {
  const CaptureControls({
    required this.selectedSum,
    required this.maxSum,
    required this.canConfirm,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final int selectedSum;
  final int maxSum;

  /// Whether the picked dice make a legal capture. "Capture" is disabled
  /// until they do.
  final bool canConfirm;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  static const double _spacing = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Capture sum: $selectedSum of up to $maxSum'),
        const SizedBox(height: _spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
            const SizedBox(width: _spacing),
            FilledButton(
              onPressed: canConfirm ? onConfirm : null,
              child: const Text('Capture'),
            ),
          ],
        ),
      ],
    );
  }
}
