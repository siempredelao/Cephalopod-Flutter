import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/view/capture_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = CaptureTextMapper();

  group('CaptureTextMapper', () {
    test('gives the sum picked so far and its limit', () {
      const capture = CaptureUi(selectedSum: 4, maxSum: 6, canConfirm: true);

      expect(mapper.map(capture), 'Capture sum: 4 of up to 6');
    });
  });
}
