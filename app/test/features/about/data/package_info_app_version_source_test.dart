import 'package:cephalopod/features/about/data/package_info_app_version_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  final reasons = <String?>[];

  void report(Object error, StackTrace stackTrace, {String? reason}) =>
      reasons.add(reason);

  setUp(reasons.clear);

  group('packageInfoAppVersionSource', () {
    test('gives the version and build number the platform reports', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Cephalopod',
        packageName: 'dev.example.cephalopod',
        version: '1.2.0',
        buildNumber: '14',
        buildSignature: '',
      );

      final version = await packageInfoAppVersionSource(
        errorReporter: report,
      )();

      expect(version, (name: '1.2.0', buildNumber: '14'));
      expect(reasons, isEmpty);
    });

    test('reports a plugin that fails, and gives no version', () async {
      final source = packageInfoAppVersionSource(
        errorReporter: report,
        packageInfo: () =>
            Future.error(PlatformException(code: 'package-info-failed')),
      );

      expect(await source(), isNull);
      expect(reasons, ['reading the app version']);
    });

    test('does not hide a bug in the plugin', () async {
      final source = packageInfoAppVersionSource(
        errorReporter: report,
        packageInfo: () => Future.error(StateError('a bug')),
      );

      await expectLater(source(), throwsStateError);
      expect(reasons, isEmpty);
    });
  });
}
