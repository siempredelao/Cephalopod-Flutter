import 'dart:io';

import 'package:flutter/services.dart';

/// Makes widget tests draw text in Roboto, the font a phone uses, instead of
/// the test font, Ahem, and draw icons as they look on a phone.
///
/// Ahem draws every letter as a square as wide as it is tall, about twice the
/// width of a real font, so text wraps and overflows in a test where it would
/// not on a phone. Without the Material icons font, icons are empty boxes.
/// Both fonts come with the Flutter SDK, which `flutter test` sets in
/// `FLUTTER_ROOT`. Call it from `setUpAll`.
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
  final icons = FontLoader('MaterialIcons');
  for (final file in folder.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    final font = Future.value(ByteData.sublistView(file.readAsBytesSync()));
    if (name.startsWith('Roboto-') && name.endsWith('.ttf')) {
      roboto.addFont(font);
    } else if (name == 'MaterialIcons-Regular.otf') {
      icons.addFont(font);
    }
  }
  await Future.wait([roboto.load(), icons.load()]);
}
