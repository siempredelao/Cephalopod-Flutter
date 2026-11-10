import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod/features/about/about_module.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/game_module.dart';
import 'package:cephalopod/features/home/home_module.dart';
import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:cephalopod/features/settings/settings_module.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shows the whole app at [location], wired as `bootstrap` wires it, with
/// storage in memory, and waits for it to settle.
Future<void> pumpApp(
  WidgetTester tester, {
  Flavor flavor = Flavor.prod,
  String location = '/',
}) async {
  final settings = SettingsModule(
    settingsRepository: InMemorySettingsRepository(),
  );
  final game = GameModule(
    cephalopodRules: CephalopodRules(),
    gameRepository: InMemoryGameRepository(),
    highlightLastMove: settings.highlightLastMove,
  );
  final router = createRouter(
    home: HomeModule(hasGameToContinue: game.hasGameToContinue),
    features: [game, settings, const AboutModule()],
    initialLocation: location,
  );
  await tester.pumpWidget(
    App(flavor: flavor, router: router, settings: settings.store),
  );
  await tester.pumpAndSettle();
}
