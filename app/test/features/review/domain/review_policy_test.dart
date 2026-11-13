import 'package:cephalopod/features/review/domain/review_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isTimeToAskForReview', () {
    test('asks after the third game and after the tenth', () {
      expect(isTimeToAskForReview(3), isTrue);
      expect(isTimeToAskForReview(10), isTrue);
    });

    test('does not ask after any other game', () {
      for (final finished in [0, 1, 2, 4, 5, 9, 11, 30, 100]) {
        expect(isTimeToAskForReview(finished), isFalse, reason: '$finished');
      }
    });
  });
}
