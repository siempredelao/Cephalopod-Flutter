import 'package:cephalopod/features/review/data/in_app_review_requester.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review_platform_interface/in_app_review_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// in_app_review's platform side, which records what it was asked and
/// answers as a test says, so no phone or store is needed.
final class _FakeInAppReview extends InAppReviewPlatform
    with MockPlatformInterfaceMixin {
  /// What [isAvailable] answers, or throws when it is an exception or an
  /// error.
  Object available = true;

  /// How many times the review sheet was asked for.
  int requests = 0;

  @override
  Future<bool> isAvailable() async {
    final available = this.available;
    if (available is Exception) throw available;
    if (available is Error) throw available;
    return available as bool;
  }

  @override
  Future<void> requestReview() async => requests++;
}

void main() {
  final reasons = <String?>[];
  late _FakeInAppReview store;

  void report(Object error, StackTrace stackTrace, {String? reason}) =>
      reasons.add(reason);

  setUp(() {
    reasons.clear();
    store = _FakeInAppReview();
    InAppReviewPlatform.instance = store;
  });

  group('inAppReviewRequester', () {
    test('asks the store for its review sheet', () async {
      await inAppReviewRequester(errorReporter: report)();

      expect(store.requests, 1);
      expect(reasons, isEmpty);
    });

    test('does not ask when the phone cannot show the sheet', () async {
      store.available = false;

      await inAppReviewRequester(errorReporter: report)();

      expect(store.requests, 0);
      expect(reasons, isEmpty);
    });

    test('reports a plugin that fails, and goes on', () async {
      store.available = Exception('no Play Store');

      await inAppReviewRequester(errorReporter: report)();

      expect(store.requests, 0);
      expect(reasons, ['asking for a review']);
    });

    test('lets an error, which is a bug, through', () async {
      store.available = StateError('a bug');

      await expectLater(
        inAppReviewRequester(errorReporter: report)(),
        throwsStateError,
      );
    });
  });
}
