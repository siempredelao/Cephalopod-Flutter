import 'dart:io';

import 'package:flutter/services.dart';

/// Makes widget tests draw text in Roboto, the font a phone uses, instead of
/// the test font, Ahem.
///
/// Ahem draws every letter as a square as wide as it is tall, about twice the
/// width of a real font, so text wraps and overflows in a test where it would
/// not on a phone. Roboto comes with the Flutter SDK, which `flutter test`
/// sets in `FLUTTER_ROOT`. Call it from `setUpAll`.
Future<void> loadRealFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    throw StateError('FLUTTER_ROOT is not set; run the tests with flutter.');
  }
  final folder = Directory.fromUri(
    Directory(root).uri.resolve('bin/cache/artifacts/material_fonts/'),
  );
  if (!folder.existsSync()) {
    throw StateError('Roboto is not in the Flutter SDK at ${folder.path}.');
  }
  final roboto = FontLoader('Roboto');
  for (final file in folder.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (name.startsWith('Roboto-') && name.endsWith('.ttf')) {
      roboto.addFont(
        Future.value(ByteData.sublistView(file.readAsBytesSync())),
      );
    }
  }
  await roboto.load();
}
