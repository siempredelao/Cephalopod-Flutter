/// Counts one more finished game on this device, remembers the new total,
/// and returns it: 1 for the first game ever. The count is what tells the
/// app when to ask for a review.
///
/// When the count cannot be kept, it returns 0, which is never a time to
/// ask: a broken store must not make the app ask again and again.
typedef FinishedGameRecorder = Future<int> Function();
