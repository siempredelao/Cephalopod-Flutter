import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Writes the game's two sounds, made from plain sine waves, so they are
/// ours and need no licence:
///
/// - `app/assets/sounds/capture.wav`: a short, soft pop for a capture.
/// - `app/assets/sounds/win.wav`: a rising chime of four notes for a win.
///
/// Usage: `dart run tool/make_sounds.dart`, from the repository root. The
/// same script always writes the same files, so running it again changes
/// nothing unless the sounds below change.
void main() {
  final folder = Directory('app/assets/sounds')..createSync(recursive: true);
  File('${folder.path}/capture.wav').writeAsBytesSync(_wav(_capture()));
  File('${folder.path}/win.wav').writeAsBytesSync(_wav(_win()));
  stdout.writeln('Wrote capture.wav and win.wav to ${folder.path}.');
}

/// Samples per second: enough for these simple tones, and small files.
const int _sampleRate = 22050;

/// How loud the sounds are at their peak, from 0 to 1, leaving room so that
/// tones played together never clip.
const double _peak = 0.7;

/// A pop of 0.15 seconds: a tone that drops from 880 Hz to 220 Hz as it
/// dies away, so it sounds like a bubble bursting rather than a beep.
List<double> _capture() {
  const seconds = 0.15;
  const startHz = 880.0;
  const endHz = 220.0;
  final count = (seconds * _sampleRate).round();
  final samples = List<double>.filled(count, 0);
  var phase = 0.0;
  for (var i = 0; i < count; i++) {
    final t = i / _sampleRate;
    final progress = t / seconds;
    // The pitch falls quickly at first, then more slowly.
    final hz = endHz + (startHz - endHz) * math.pow(1 - progress, 2);
    phase += 2 * math.pi * hz / _sampleRate;
    samples[i] = math.sin(phase) * _envelope(t, attack: 0.003, decay: 0.04);
  }
  return _normalized(samples);
}

/// A chime of 1.5 seconds: C, E, G and the C above, a major chord played
/// upwards, one note every 0.12 seconds. Each note rings like a small bell
/// and dies away over the rest of the sound.
List<double> _win() {
  const seconds = 1.5;
  const noteGap = 0.12;
  const notesHz = [523.25, 659.25, 783.99, 1046.5];
  final count = (seconds * _sampleRate).round();
  final samples = List<double>.filled(count, 0);
  for (final (index, hz) in notesHz.indexed) {
    final start = (index * noteGap * _sampleRate).round();
    for (var i = start; i < count; i++) {
      final t = (i - start) / _sampleRate;
      samples[i] += _bell(hz, t) * _envelope(t, attack: 0.005, decay: 0.35);
    }
  }
  return _normalized(samples);
}

/// A bell-like tone of [hz] at [t] seconds: the note, with a quieter
/// octave and twelfth above it for shine.
double _bell(double hz, double t) {
  double tone(double partialHz) => math.sin(2 * math.pi * partialHz * t);
  return tone(hz) + 0.4 * tone(2 * hz) + 0.15 * tone(3 * hz);
}

/// How loud a sound is [t] seconds after it starts: it rises over [attack]
/// seconds, so it does not click, then dies away, losing about two thirds of
/// its loudness every [decay] seconds.
double _envelope(double t, {required double attack, required double decay}) {
  final rise = math.min(1, t / attack);
  return rise * math.exp(-t / decay);
}

/// [samples] scaled so the loudest is at [_peak], and faded out over the
/// last few milliseconds, so the sound ends without a click.
List<double> _normalized(List<double> samples) {
  final loudest = samples.fold<double>(0, (most, s) => math.max(most, s.abs()));
  const fadeOut = 0.005;
  final fadeCount = (fadeOut * _sampleRate).round();
  return [
    for (final (i, sample) in samples.indexed)
      sample /
          loudest *
          _peak *
          math.min(1, (samples.length - 1 - i) / fadeCount),
  ];
}

/// [samples], from -1 to 1, as the bytes of a mono, 16-bit WAV file.
Uint8List _wav(List<double> samples) {
  const bytesPerSample = 2;
  const headerSize = 44;
  final dataSize = samples.length * bytesPerSample;
  final bytes = ByteData(headerSize + dataSize);

  void ascii(int offset, String text) {
    for (final (i, unit) in text.codeUnits.indexed) {
      bytes.setUint8(offset + i, unit);
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, headerSize - 8 + dataSize, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  bytes
    ..setUint32(16, 16, Endian.little) // Size of the format chunk.
    ..setUint16(20, 1, Endian.little) // PCM, no compression.
    ..setUint16(22, 1, Endian.little) // One channel.
    ..setUint32(24, _sampleRate, Endian.little)
    ..setUint32(28, _sampleRate * bytesPerSample, Endian.little)
    ..setUint16(32, bytesPerSample, Endian.little)
    ..setUint16(34, 16, Endian.little); // Bits per sample.
  ascii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);
  for (final (i, sample) in samples.indexed) {
    final value = (sample.clamp(-1.0, 1.0) * 32767).round();
    bytes.setInt16(headerSize + i * bytesPerSample, value, Endian.little);
  }
  return bytes.buffer.asUint8List();
}
