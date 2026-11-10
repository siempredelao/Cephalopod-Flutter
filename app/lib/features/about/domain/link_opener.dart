/// Opens a web address outside the app, in the browser, and says whether it
/// did.
typedef LinkOpener = Future<bool> Function(Uri address);
