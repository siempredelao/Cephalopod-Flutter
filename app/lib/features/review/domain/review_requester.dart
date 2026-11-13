/// Asks the store to show its review sheet, if the phone can.
///
/// The store decides whether the sheet shows: it limits how often one can,
/// and a phone without the store cannot show it at all. So this says
/// nothing about what happened, and never fails.
typedef ReviewRequester = Future<void> Function();
