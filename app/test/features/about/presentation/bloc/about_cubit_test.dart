import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/presentation/bloc/about_cubit.dart';
import 'package:cephalopod/features/about/presentation/models/about_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ruleSheet = Uri.parse('https://example.org/rules.pdf');
  const start = AboutViewState(
    ruleSheetAddress: 'https://example.org/rules.pdf',
  );

  AboutCubit build({AppVersionSource? appVersionSource}) {
    return AboutCubit(
      appVersionSource:
          appVersionSource ?? () async => (name: '1.2.0', buildNumber: '14'),
      ruleSheet: ruleSheet,
    );
  }

  group('AboutCubit', () {
    test('starts with the rule sheet address and no version yet', () {
      expect(build().state, start);
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
  });
}
