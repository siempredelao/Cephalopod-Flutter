import 'package:cephalopod/features/game/domain/sound_effects.dart';

/// [SoundEffects] that play nothing and remember what they were asked to
/// play, in order: `capture` or `win`.
final class FakeSoundEffects implements SoundEffects {
  final List<String> played = [];

  @override
  Future<void> playCapture() async => played.add('capture');

  @override
  Future<void> playWin() async => played.add('win');
}
