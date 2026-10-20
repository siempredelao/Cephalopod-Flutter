/// Rules engine for Cephalopod, the dice game invented by Mark Steere in
/// 2006.
///
/// The engine is pure Dart: it never imports Flutter, performs no I/O and
/// reads no clock, so every rule can be unit-tested in milliseconds and
/// reused by the app, an AI opponent or a game server.
///
/// Rule sheet: https://www.marksteeregames.com/Cephalopod_rules.pdf
library;

export 'src/model/player.dart';
