import 'package:cephalopod/features/how_to_play/domain/how_to_play_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// What every [HowToPlayRepository] must do. Each implementation's test
/// calls this with a way to create a fresh, empty repository.
void testHowToPlayRepositoryContract(
  Future<HowToPlayRepository> Function() create,
) {
  group('HowToPlayRepository contract', () {
    late HowToPlayRepository repository;

    setUp(() async => repository = await create());

    test('has not shown How to play before it is marked', () async {
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
