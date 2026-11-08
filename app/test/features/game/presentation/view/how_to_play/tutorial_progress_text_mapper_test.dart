import 'package:cephalopod/features/game/presentation/view/how_to_play/tutorial_progress_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = TutorialProgressTextMapper();

  group('TutorialProgressTextMapper', () {
    test('counts the steps from 1', () {
      expect(mapper.map(currentStep: 0, stepCount: 6), 'Step 1 of 6');
      expect(mapper.map(currentStep: 5, stepCount: 6), 'Step 6 of 6');
    });
  });
}
