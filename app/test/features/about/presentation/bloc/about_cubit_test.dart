import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/domain/link_opener.dart';
import 'package:cephalopod/features/about/domain/models/credits.dart';
import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final website = Uri.parse('https://www.example.org');
  final ruleSheet = Uri.parse('https://www.example.org/rules.pdf');
  const start = AboutViewState(
    copyright: 'Copyright © 1999 by Someone',
    websiteName: 'example.org',
  );
  final opened = <Uri>[];

  AboutCubit build({
    AppVersionSource? appVersionSource,
    LinkOpener? linkOpener,
    Uri? websiteAddress,
  }) {
    return AboutCubit(
      appVersionSource:
          appVersionSource ?? () async => (name: '1.2.0', buildNumber: '14'),
      linkOpener:
          linkOpener ??
          (address) async {
            opened.add(address);
            return true;
          },
      credits: (
        copyright: 'Copyright © 1999 by Someone',
        website: websiteAddress ?? website,
        ruleSheet: ruleSheet,
      ),
    );
  }

  setUp(opened.clear);

  group('AboutCubit', () {
    test('starts with the credits, and no version or failed link', () {
      expect(build().state, start);
    });

    test('names a website without www as its address does', () {
      final cubit = build(websiteAddress: Uri.parse('https://example.com'));

      expect(cubit.state.websiteName, 'example.com');
    });

    test('gives Cephalopod the copyright and website of Mark Steere', () {
      final cubit = AboutCubit(
        appVersionSource: () async => null,
        linkOpener: (_) async => true,
        credits: cephalopodCredits,
      );

      expect(
        cubit.state,
        const AboutViewState(
          copyright: 'Copyright © February 2006 by Mark Steere',
          websiteName: 'marksteeregames.com',
        ),
      );
    });

    blocTest<AboutCubit, AboutViewState>(
      'shows the version once it is known',
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        start.copyWith(version: (version: '1.2.0', build: '14')),
      ],
    );

    blocTest<AboutCubit, AboutViewState>(
      'shows no version when it cannot be known',
      build: () => build(appVersionSource: () async => null),
      act: (cubit) => cubit.load(),
      expect: () => <AboutViewState>[],
    );

    test('does not show a version that arrives after it closes', () async {
      final cubit = build(
        appVersionSource: () async {
          await Future<void>.delayed(Duration.zero);
          return (name: '1.2.0', buildNumber: '14');
        },
      );

      final loading = cubit.load();
      await cubit.close();
      await loading;

      expect(cubit.state, start);
    });

    test('opens the website and the rule sheet, each its own', () async {
      final cubit = build();

      await cubit.openWebsite();
      await cubit.openRuleSheet();

      expect(opened, [website, ruleSheet]);
      expect(cubit.state.failedLinkAddress, isNull);
      await cubit.close();
    });

    blocTest<AboutCubit, AboutViewState>(
      'gives the address of a link that does not open, until one does',
      build: () {
        var opens = 0;
        return build(linkOpener: (_) async => ++opens > 2);
      },
      act: (cubit) async {
        await cubit.openRuleSheet();
        await cubit.openWebsite();
        await cubit.openWebsite();
      },
      expect: () => [
        start.copyWith(
          failedLinkAddress: 'https://www.example.org/rules.pdf',
        ),
        start.copyWith(failedLinkAddress: 'https://www.example.org'),
        start,
      ],
    );

    test('does not report a link that answers after it closes', () async {
      final cubit = build(
        linkOpener: (_) async {
          await Future<void>.delayed(Duration.zero);
          return false;
        },
      );

      final opening = cubit.openRuleSheet();
      await cubit.close();
      await opening;

      expect(cubit.state, start);
    });
  });
}
