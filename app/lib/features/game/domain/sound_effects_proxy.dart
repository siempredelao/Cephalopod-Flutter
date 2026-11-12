import 'package:cephalopod/features/game/domain/sound_effects.dart';

/// [SoundEffects] that pass each sound on to other [SoundEffects] only while
/// sound is on, so whoever plays a sound need not ask whether it should be
/// heard. A proxy: it stands in for the real sounds, with the same calls,
/// and decides which get through.
///
/// It asks `soundOn` at every sound, so it follows the Sound switch in
/// Settings as it is when the sound plays.
final class SoundEffectsProxy implements SoundEffects {
  SoundEffectsProxy({
    required this._soundEffects,
    required this._soundOn,
  });

  final SoundEffects _soundEffects;
  final bool Function() _soundOn;

  @override
  Future<void> playCapture() async {
    if (_soundOn()) await _soundEffects.playCapture();
  }

  @override
  Future<void> playWin() async {
    if (_soundOn()) await _soundEffects.playWin();
  }
}
