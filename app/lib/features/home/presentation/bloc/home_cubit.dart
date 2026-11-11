import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/home/presentation/models/home_view_state.dart';

/// Home's view model. Its [HomeViewState] says whether there is a saved
/// game to continue, so Home knows whether to offer Continue, and whether to
/// open How to play by itself.
///
/// It starts without a game to continue and asks again on [refresh]: when
/// Home opens and each time the player comes back from a game. The first
/// [refresh] also asks whether How to play was ever shown; if not, Home
/// opens it, once, and says so with [howToPlayOpened].
class HomeCubit extends Cubit<HomeViewState> {
  /// `hasGameToContinue` and `hasSeenHowToPlay` are plain functions rather
  /// than the game feature's own code, because features may not import each
  /// other. The composition root wires them to the game module.
  HomeCubit({
    required this._hasGameToContinue,
    required this._hasSeenHowToPlay,
  }) : super(const HomeViewState(canContinue: false));

  final Future<bool> Function() _hasGameToContinue;
  final Future<bool> Function() _hasSeenHowToPlay;

  /// Whether [refresh] has asked about How to play yet. It asks only once:
  /// How to play marks itself seen when it opens.
  bool _askedAboutHowToPlay = false;

  /// Asks again whether there is a saved game to continue, and, the first
  /// time, whether How to play should open.
  Future<void> refresh() async {
    final firstTime = !_askedAboutHowToPlay;
    _askedAboutHowToPlay = true;
    final canContinue = await _hasGameToContinue();
    final showHowToPlay = firstTime && !await _hasSeenHowToPlay();
    // Home may have closed while storage answered.
    if (isClosed) return;
    emit(
      state.copyWith(
        canContinue: canContinue,
        showHowToPlay: state.showHowToPlay || showHowToPlay,
      ),
    );
  }

  /// Home has opened How to play, so it no longer needs to.
  void howToPlayOpened() => emit(state.copyWith(showHowToPlay: false));
}
