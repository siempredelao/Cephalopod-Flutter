import 'package:cephalopod/features/game/presentation/models/capture_ui.dart';
import 'package:cephalopod/features/game/presentation/view/capture_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/translations.dart';

void main() {
  const mapper = CaptureTextMapper();
  const capture = CaptureUi(selectedSum: 4, maxSum: 6, canConfirm: true);

  group('CaptureTextMapper', () {
    test('gives the sum picked so far and its limit', () {
      expect(mapper.map(capture, english), 'Capture sum: 4 of up to 6');
    });

    test('speaks Spanish', () {
      expect(
        mapper.map(capture, spanish),
        'Suma de la captura: 4 de 6 como máximo',
      );
    });
  });
}
