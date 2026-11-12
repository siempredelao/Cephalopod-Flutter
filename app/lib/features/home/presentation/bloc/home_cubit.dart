import 'package:bloc/bloc.dart';
import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_script.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_ui_mapper.dart';
import 'package:cephalopod/features/home/presentation/bloc/saved_game_ui_mapper.dart';
import 'package:cephalopod/features/home/presentation/models/demo_ui.dart';
import 'package:cephalopod/features/home/presentation/models/home_view_state.dart';

/// Home's view model. Its [HomeViewState] carries the saved game to
/// continue, if there is one, so Home knows whether to offer Continue and
/// what the offer shows, and whether to open How to play by itself.
///
/// It starts without a game to continue and asks again on [refresh]: when
/// Home opens and each time the player comes back from a game. The first
/// [refresh] also asks whether How to play was ever shown; if not, Home
/// opens it, once, and says so with [howToPlayOpened].
class HomeCubit extends Cubit<HomeViewState> {
  /// `savedGameSummary` and `hasSeenHowToPlay` are plain functions rather
  /// than other features' own code, because features may not import each
  /// other. The composition root wires them to the game and How to play
  /// modules.
  HomeCubit({
    required this._savedGameSummary,
    required this._hasSeenHowToPlay,
    DemoUiMapper demoUiMapper = const DemoUiMapper(),
    this._savedGameUiMapper = const SavedGameUiMapper(),
  }) : demo = demoUiMapper.map(homeDemoScript),
       super(const HomeViewState());

  /// The demo Home plays above the title. It is the same for as long as
  /// Home is open, so it is not part of [state].
  final DemoUi demo;

  final Future<SavedGameSummary?> Function() _savedGameSummary;
  final SavedGameUiMapper _savedGameUiMapper;
  final Future<bool> Function() _hasSeenHowToPlay;

  /// Whether [refresh] has asked about How to play yet. It asks only once:
  /// How to play marks itself seen when it opens.
  bool _askedAboutHowToPlay = false;

  /// Asks again whether there is a saved game to continue, and, the first
  /// time, whether How to play should open.
  Future<void> refresh() async {
    final firstTime = !_askedAboutHowToPlay;
    _askedAboutHowToPlay = true;
    final summary = await _savedGameSummary();
    final showHowToPlay = firstTime && !await _hasSeenHowToPlay();
    // Home may have closed while storage answered.
    if (isClosed) return;
    emit(
      state.copyWith(
        savedGame: summary == null ? null : _savedGameUiMapper.map(summary),
        showHowToPlay: state.showHowToPlay || showHowToPlay,
      ),
    );
  }

  /// Home has opened How to play, so it no longer needs to.
  void howToPlayOpened() => emit(state.copyWith(showHowToPlay: false));
}
