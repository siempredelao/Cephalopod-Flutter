import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/about/domain/link_opener.dart';
import 'package:url_launcher/url_launcher.dart';

/// A [LinkOpener] that opens the address in the browser with url_launcher
/// (docs/adr/0020).
///
/// A link that does not open never stops the app: when the plugin fails,
/// the error goes to [errorReporter] and the answer is `false`. Only
/// `Exception`s are caught; an `Error` is a bug, so it goes on to the
/// app-wide error reporting.
LinkOpener urlLauncherLinkOpener({required ErrorReporter errorReporter}) {
  return (address) async {
    try {
      return await launchUrl(address, mode: LaunchMode.externalApplication);
    } on Exception catch (error, stackTrace) {
      errorReporter(error, stackTrace, reason: 'opening a link');
      return false;
    }
  };
}
