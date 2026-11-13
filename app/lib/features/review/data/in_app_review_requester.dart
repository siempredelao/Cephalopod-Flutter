import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/review/domain/review_requester.dart';
import 'package:in_app_review/in_app_review.dart';

/// A [ReviewRequester] that asks Google Play for its review sheet with
/// in_app_review (docs/adr/0022).
///
/// It asks only when the phone can show the sheet. A request that fails
/// never stops the app: the error goes to [errorReporter]. Only
/// `Exception`s are caught; an `Error` is a bug, so it goes on to the
/// app-wide error reporting.
ReviewRequester inAppReviewRequester({required ErrorReporter errorReporter}) {
  return () async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    } on Exception catch (error, stackTrace) {
      errorReporter(error, stackTrace, reason: 'asking for a review');
    }
  };
}
