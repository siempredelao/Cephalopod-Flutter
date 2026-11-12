import 'package:audioplayers/audioplayers.dart';
import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/game/domain/sound_effects.dart';

/// [SoundEffects] played with audioplayers (docs/adr/0021), from the files
/// in `assets/sounds/`.
///
/// Each sound has a player of its own, made the first time the sound plays,
/// so a win never cuts off a capture's pop, and an app that plays no sound
/// makes no player. Both play in low-latency mode, meant for short sounds
/// that must start at once.
///
/// A low-latency player on Android is never told that its sound has ended,
/// so it would take itself to be still playing and ignore every play after
/// the first. Each play therefore stops the player first. The player keeps
/// its sound loaded when it stops (`ReleaseMode.stop`), so the sound need
/// not be read again.
///
/// A sound that does not play never stops the game: when the plugin fails,
/// the error goes to [_errorReporter] and nothing is heard. Only
/// `Exception`s are caught; an `Error` is a bug, so it goes on to the
/// app-wide error reporting.
final class AudioplayersSoundEffects implements SoundEffects {
  /// [_newPlayer] makes a player; tests replace it with a fake one.
  AudioplayersSoundEffects({
    required this._errorReporter,
    this._newPlayer = AudioPlayer.new,
  });

  final ErrorReporter _errorReporter;
  final AudioPlayer Function() _newPlayer;

  late final AudioPlayer _capturePlayer = _newPlayer();
  late final AudioPlayer _winPlayer = _newPlayer();

  /// The game's sounds play on the media volume, as other games' do, and
  /// leave the player's own music playing: on Android they do not ask for
  /// the audio focus, and on iOS they mix with other audio and keep quiet
  /// when the Silent switch is on.
  static final AudioContext _context = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  @override
  Future<void> playCapture() => _play(_capturePlayer, 'sounds/capture.wav');

  @override
  Future<void> playWin() => _play(_winPlayer, 'sounds/win.wav');

  /// Plays [asset], a path under `assets/`, on [player], from its start.
  Future<void> _play(AudioPlayer player, String asset) async {
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.stop();
      await player.play(
        AssetSource(asset),
        mode: PlayerMode.lowLatency,
        ctx: _context,
      );
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'playing a sound');
    }
  }
}
