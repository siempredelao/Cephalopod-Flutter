import 'package:cephalopod/features/home/domain/first_launch_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// What every [FirstLaunchRepository] must do. Each implementation's test
/// calls this with a way to create a fresh, empty repository.
void testFirstLaunchRepositoryContract(
  Future<FirstLaunchRepository> Function() create,
) {
  group('FirstLaunchRepository contract', () {
    late FirstLaunchRepository repository;

    setUp(() async => repository = await create());

    test('has not shown How to play on a first launch', () async {
      expect(await repository.hasSeenHowToPlay(), isFalse);
    });

    test('remembers that How to play was shown', () async {
      await repository.markHowToPlaySeen();

      expect(await repository.hasSeenHowToPlay(), isTrue);
    });

    test('stays seen when marked again', () async {
      await repository.markHowToPlaySeen();
      await repository.markHowToPlaySeen();

      expect(await repository.hasSeenHowToPlay(), isTrue);
    });
  });
}
