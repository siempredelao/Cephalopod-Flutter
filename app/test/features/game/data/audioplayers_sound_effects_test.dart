import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cephalopod/features/game/data/audioplayers_sound_effects.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A player that records what it was asked to play, so no device is
/// needed. It throws [failure] when one is set.
final class _FakeAudioPlayer extends Fake implements AudioPlayer {
  final List<({Source source, PlayerMode? mode, AudioContext? ctx})> plays = [];

  Exception? failure;

  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    plays.add((source: source, mode: mode, ctx: ctx));
    if (failure case final failure?) throw failure;
  }
}

void main() {
  final players = <_FakeAudioPlayer>[];
  final reasons = <String?>[];

  void report(Object error, StackTrace stackTrace, {String? reason}) =>
      reasons.add(reason);

  AudioplayersSoundEffects soundEffects() => AudioplayersSoundEffects(
    errorReporter: report,
    newPlayer: () {
      final player = _FakeAudioPlayer();
      players.add(player);
      return player;
    },
  );

  /// The file that [player] last played, from the app's folder.
  String fileOf(_FakeAudioPlayer player) =>
      'assets/${(player.plays.last.source as AssetSource).path}';

  setUp(() {
    players.clear();
    reasons.clear();
  });

  group('AudioplayersSoundEffects', () {
    test('makes no player until a sound plays', () {
      soundEffects();

      expect(players, isEmpty);
    });

    test('plays the capture sound, at once', () async {
      await soundEffects().playCapture();

      final play = players.single.plays.single;
      expect(fileOf(players.single), 'assets/sounds/capture.wav');
      expect(play.mode, PlayerMode.lowLatency);
      expect(reasons, isEmpty);
    });

    test('plays the win sound, at once', () async {
      await soundEffects().playWin();

      final play = players.single.plays.single;
      expect(fileOf(players.single), 'assets/sounds/win.wav');
      expect(play.mode, PlayerMode.lowLatency);
    });

    test('plays sounds that are in the app', () async {
      final sounds = soundEffects();
      await sounds.playCapture();
      await sounds.playWin();

      for (final player in players) {
        expect(File(fileOf(player)).existsSync(), isTrue, reason: '$player');
      }
    });

    test('gives each sound a player of its own, made once', () async {
      final sounds = soundEffects();

      await sounds.playCapture();
      await sounds.playWin();
      await sounds.playCapture();

      expect(players, hasLength(2));
      expect(players.first.plays, hasLength(2));
      expect(players.last.plays, hasLength(1));
    });

    test("leaves the player's own music playing", () async {
      await soundEffects().playCapture();

      final context = players.single.plays.single.ctx!;
      expect(context.android.audioFocus, AndroidAudioFocus.none);
      expect(context.android.usageType, AndroidUsageType.game);
      expect(context.iOS.category, AVAudioSessionCategory.ambient);
    });

    test('reports a player that fails, and carries on', () async {
      final sounds = soundEffects();
      await sounds.playCapture();
      players.single.failure = PlatformException(code: 'no-audio');

      await sounds.playCapture();

      expect(reasons, ['playing a sound']);
    });
  });
}
