import 'package:cephalopod/features/about/data/url_launcher_link_opener.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// url_launcher's platform side, which records what it was asked to open
/// and answers as a test says, so no device or browser is needed.
final class _FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  @override
  LinkDelegate? get linkDelegate => null;

  /// What [launchUrl] answers, or throws when it is an exception.
  Object answer = true;

  final List<String> urls = [];
  final List<LaunchOptions> options = [];

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    this.options.add(options);
    final answer = this.answer;
    if (answer is Exception) throw answer;
    return answer as bool;
  }
}

void main() {
  final address = Uri.parse('https://example.org/rules.pdf');
  final reasons = <String?>[];
  late _FakeUrlLauncher launcher;

  void report(Object error, StackTrace stackTrace, {String? reason}) =>
      reasons.add(reason);

  setUp(() {
    reasons.clear();
    launcher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
  });

  group('urlLauncherLinkOpener', () {
    test('opens the address in the browser, outside the app', () async {
      final opened = await urlLauncherLinkOpener(errorReporter: report)(
        address,
      );

      expect(opened, isTrue);
      expect(launcher.urls, ['https://example.org/rules.pdf']);
      expect(
        launcher.options.single.mode,
        PreferredLaunchMode.externalApplication,
      );
      expect(reasons, isEmpty);
    });

    test('says so when nothing could open the address', () async {
      launcher.answer = false;

      final opened = await urlLauncherLinkOpener(errorReporter: report)(
        address,
      );

      expect(opened, isFalse);
    });

    test('reports a plugin that fails, and says it did not open', () async {
      launcher.answer = PlatformException(code: 'launch-failed');

      final opened = await urlLauncherLinkOpener(errorReporter: report)(
        address,
      );

      expect(opened, isFalse);
      expect(reasons, ['opening a link']);
    });
  });
}
