import 'dart:async';

import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod/features/about/about_module.dart';
import 'package:cephalopod/features/game/data/game_record_json_codec.dart';
import 'package:cephalopod/features/game/data/shared_preferences_game_repository.dart';
import 'package:cephalopod/features/game/game_module.dart';
import 'package:cephalopod/features/home/home_module.dart';
import 'package:cephalopod/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:cephalopod/features/settings/settings_module.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: the only code that picks concrete implementations,
/// such as device storage, and connects features to each other. Each
/// feature's module wires the rest of that feature, and everything else
/// receives its dependencies through constructors.
void bootstrap(Flavor flavor) {
  // Storage plugins are used before runApp, so the bindings come first.
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = SharedPreferencesAsync();

  final settings = SettingsModule(
    repository: SharedPreferencesSettingsRepository(preferences: preferences),
  );
  // Shows the defaults for the moment the saved settings take to load.
  unawaited(settings.cubit.load());

  final game = GameModule(
    rules: CephalopodRules(),
    repository: SharedPreferencesGameRepository(
      preferences: preferences,
      codec: GameRecordJsonCodec(),
    ),
    highlightLastMove: settings.highlightLastMove,
  );
  final router = createRouter(
    home: HomeModule(hasGameToContinue: game.hasGameToContinue),
    features: [game, settings, const AboutModule()],
  );

  runApp(App(flavor: flavor, router: router, settings: settings.cubit));
}
