import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';

/// Words the capture being chosen: "Capture sum: 3 of up to 6".
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class CaptureTextMapper {
  const CaptureTextMapper();

  String map(CaptureUi capture) {
    return 'Capture sum: ${capture.selectedSum} of up to ${capture.maxSum}';
  }
}
