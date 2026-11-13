import 'dart:async';

import 'package:cephalopod/app/app.dart';
import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/log_error.dart';
import 'package:cephalopod/app/router.dart';
import 'package:cephalopod/app/uncaught_error_reporting.dart';
import 'package:cephalopod/features/about/about_module.dart';
import 'package:cephalopod/features/about/data/package_info_app_version_source.dart';
import 'package:cephalopod/features/about/data/url_launcher_link_opener.dart';
import 'package:cephalopod/features/game/data/audioplayers_sound_effects.dart';
import 'package:cephalopod/features/game/data/saved_game_json_codec.dart';
import 'package:cephalopod/features/game/data/shared_preferences_game_repository.dart';
import 'package:cephalopod/features/game/game_module.dart';
import 'package:cephalopod/features/home/home_module.dart';
import 'package:cephalopod/features/how_to_play/data/shared_preferences_how_to_play_repository.dart';
import 'package:cephalopod/features/how_to_play/how_to_play_module.dart';
import 'package:cephalopod/features/review/data/in_app_review_requester.dart';
import 'package:cephalopod/features/review/data/shared_preferences_finished_game_recorder.dart';
import 'package:cephalopod/features/review/domain/review_prompt.dart';
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
  installUncaughtErrorReporting(logError);
  final preferences = SharedPreferencesAsync();

  final settings = SettingsModule(
    settingsRepository: SharedPreferencesSettingsRepository(
      sharedPreferencesAsync: preferences,
      // Storage that fails is reported, and the app goes on
      // (docs/adr/0016).
      errorReporter: logError,
    ),
  );
  // Shows the defaults for the moment the saved settings take to load.
  unawaited(settings.store.load());

  final reviewPrompt = ReviewPrompt(
    recordFinishedGame: sharedPreferencesFinishedGameRecorder(
      sharedPreferencesAsync: preferences,
      errorReporter: logError,
    ),
    // A review sheet that cannot show is reported, and nothing happens
    // (docs/adr/0022).
    requestReview: inAppReviewRequester(errorReporter: logError),
  );

  final game = GameModule(
    cephalopodRules: CephalopodRules(),
    gameRepository: SharedPreferencesGameRepository(
      sharedPreferencesAsync: preferences,
      savedGameJsonCodec: SavedGameJsonCodec(),
      // Storage that fails is reported, and the game goes on
      // (docs/adr/0016).
      errorReporter: logError,
    ),
    // A sound that cannot play is reported, and the game goes on
    // (docs/adr/0021).
    soundEffects: AudioplayersSoundEffects(errorReporter: logError),
    highlightLastMove: settings.highlightLastMove,
    soundOn: settings.soundOn,
    onGameFinished: () => unawaited(reviewPrompt.afterFinishedGame()),
  );
  final howToPlay = HowToPlayModule(
    howToPlayRepository: SharedPreferencesHowToPlayRepository(
      sharedPreferencesAsync: preferences,
      errorReporter: logError,
    ),
  );
  final about = AboutModule(
    appVersionSource: packageInfoAppVersionSource(errorReporter: logError),
    linkOpener: urlLauncherLinkOpener(errorReporter: logError),
  );
  final router = createRouter(
    home: HomeModule(
      savedGameSummary: game.savedGameSummary,
      hasSeenHowToPlay: howToPlay.hasSeenHowToPlay,
    ),
    features: [game, howToPlay, settings, about],
  );

  runApp(App(flavor: flavor, router: router, settings: settings.store));
}
