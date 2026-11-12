import 'package:cephalopod/features/game/domain/sound_effects_proxy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_sound_effects.dart';

void main() {
  late FakeSoundEffects sounds;
  late bool soundOn;

  SoundEffectsProxy proxy() =>
      SoundEffectsProxy(soundEffects: sounds, soundOn: () => soundOn);

  setUp(() {
    sounds = FakeSoundEffects();
    soundOn = true;
  });

  group('SoundEffectsProxy', () {
    test('plays each sound while sound is on', () async {
      final effects = proxy();

      await effects.playCapture();
      await effects.playWin();

      expect(sounds.played, ['capture', 'win']);
    });

    test('plays nothing while sound is off', () async {
      soundOn = false;
      final effects = proxy();

      await effects.playCapture();
      await effects.playWin();

      expect(sounds.played, isEmpty);
    });

    test('follows the switch as it is when each sound plays', () async {
      final effects = proxy();

      await effects.playCapture();
      soundOn = false;
      await effects.playCapture();
      soundOn = true;
      await effects.playWin();

      expect(sounds.played, ['capture', 'win']);
    });
  });
}
