import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// An [AppVersionSource] that asks the platform with package_info_plus
/// (docs/adr/0019). The version is read with [packageInfo], which is the
/// plugin's own `PackageInfo.fromPlatform` unless a test gives another.
///
/// Not knowing the version never stops the app: when the plugin fails, the
/// error goes to [errorReporter] and the version is `null`. Only
/// `Exception`s are caught; an `Error` is a bug, so it goes on to the
/// app-wide error reporting.
AppVersionSource packageInfoAppVersionSource({
  required ErrorReporter errorReporter,
  Future<PackageInfo> Function() packageInfo = PackageInfo.fromPlatform,
}) {
  return () async {
    try {
      final info = await packageInfo();
      return (name: info.version, buildNumber: info.buildNumber);
    } on Exception catch (error, stackTrace) {
      errorReporter(error, stackTrace, reason: 'reading the app version');
      return null;
    }
  };
}
