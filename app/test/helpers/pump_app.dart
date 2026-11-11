import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod/features/about/about_module.dart';
import 'package:cephalopod/features/about/domain/app_version_source.dart';
import 'package:cephalopod/features/about/domain/link_opener.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/data/in_memory_how_to_play_repository.dart';
import 'package:cephalopod/features/game/game_module.dart';
import 'package:cephalopod/features/home/home_module.dart';
import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:cephalopod/features/settings/settings_module.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shows the whole app at [location], wired as `bootstrap` wires it, with
/// storage in memory, and waits for it to settle.
///
/// The About page reads its version from [appVersionSource], and opens
/// links with [linkOpener]: by default, version 1.2.0 (build 14), and a
/// browser that opens everything.
///
/// How to play counts as already seen, so the app starts on [location]
/// rather than on How to play, as it would on a first launch. Pass
/// [firstLaunch] to start as a fresh install does.
Future<void> pumpApp(
  WidgetTester tester, {
  Flavor flavor = Flavor.prod,
  String location = '/',
  AppVersionSource? appVersionSource,
  LinkOpener? linkOpener,
  bool firstLaunch = false,
}) async {
  final settings = SettingsModule(
    settingsRepository: InMemorySettingsRepository(),
  );
  final game = GameModule(
    cephalopodRules: CephalopodRules(),
    gameRepository: InMemoryGameRepository(),
    howToPlayRepository: InMemoryHowToPlayRepository(
      seenHowToPlay: !firstLaunch,
    ),
    highlightLastMove: settings.highlightLastMove,
  );
  final about = AboutModule(
    appVersionSource:
        appVersionSource ?? () async => (name: '1.2.0', buildNumber: '14'),
    linkOpener: linkOpener ?? (_) async => true,
  );
  final router = createRouter(
    home: HomeModule(
      hasGameToContinue: game.hasGameToContinue,
      hasSeenHowToPlay: game.hasSeenHowToPlay,
    ),
    features: [game, settings, about],
    initialLocation: location,
  );
  await tester.pumpWidget(
    App(flavor: flavor, router: router, settings: settings.store),
  );
  await tester.pumpAndSettle();
}
