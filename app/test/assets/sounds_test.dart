import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sounds that `tool/make_sounds.dart` writes, as the app finds them in
/// its bundle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// How many seconds the mono, 16-bit sound in [wav] lasts.
  double secondsOf(ByteData wav) {
    final sampleRate = wav.getUint32(24, Endian.little);
    final dataSize = wav.getUint32(40, Endian.little);
    return dataSize / 2 / sampleRate;
  }

  for (final (name, shortest, longest) in [
    ('capture', 0.05, 0.2),
    ('win', 1.0, 2.0),
  ]) {
    test('bundles the $name sound as a short mono, 16-bit WAV file', () async {
      final wav = await rootBundle.load('assets/sounds/$name.wav');

      expect(String.fromCharCodes(wav.buffer.asUint8List(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wav.buffer.asUint8List(8, 4)), 'WAVE');
      expect(wav.getUint16(22, Endian.little), 1, reason: 'channels');
      expect(wav.getUint16(34, Endian.little), 16, reason: 'bits per sample');
      expect(secondsOf(wav), inInclusiveRange(shortest, longest));
    });
  }
}
