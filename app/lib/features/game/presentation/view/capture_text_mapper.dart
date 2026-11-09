import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';

/// Words the capture being chosen: "Capture sum: 3 of up to 6", in the
/// language on screen.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class CaptureTextMapper {
  const CaptureTextMapper();

  String map(CaptureUi capture, AppLocalizations l10n) {
    return l10n.captureSum(capture.selectedSum, capture.maxSum);
  }
}
