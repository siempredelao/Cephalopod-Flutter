import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/view/capture_text_mapper.dart';
import 'package:material_ui/material_ui.dart';

/// Shown while the player chooses a [capture]: the pip sum of the dice
/// picked so far, a button to capture them and one to back out.
class CaptureControls extends StatelessWidget {
  const CaptureControls({
    required this.capture,
    required this.onConfirm,
    required this.onCancel,
    this._captureTextMapper = const CaptureTextMapper(),
    super.key,
  });

  final CaptureTextMapper _captureTextMapper;

  /// The sum picked so far, its limit, and whether the picked dice make a
  /// legal capture. "Capture" is disabled until they do.
  final CaptureUi capture;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  static const double _spacing = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_captureTextMapper.map(capture, context.l10n)),
        const SizedBox(height: _spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: onCancel,
              child: Text(context.l10n.gameCaptureCancel),
            ),
            const SizedBox(width: _spacing),
            FilledButton(
              onPressed: capture.canConfirm ? onConfirm : null,
              child: Text(context.l10n.gameCaptureConfirm),
            ),
          ],
        ),
      ],
    );
  }
}
