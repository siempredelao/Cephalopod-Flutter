import 'package:cephalopod/features/how_to_play/presentation/view/tutorial_progress_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/translations.dart';

void main() {
  const mapper = TutorialProgressTextMapper();

  group('TutorialProgressTextMapper', () {
    test('counts the steps from 1', () {
      expect(
        mapper.map(english, currentStep: 0, stepCount: 6),
        'Step 1 of 6',
      );
      expect(
        mapper.map(english, currentStep: 5, stepCount: 6),
        'Step 6 of 6',
      );
    });

    test('speaks Spanish', () {
      expect(
        mapper.map(spanish, currentStep: 1, stepCount: 6),
        'Paso 2 de 6',
      );
    });
  });
}
