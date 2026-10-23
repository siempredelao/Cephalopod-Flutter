import 'package:bloc/bloc.dart';

/// Home's view model. Its state is whether there is a saved game to
/// continue, so Home knows whether to offer Continue.
///
/// It starts at `false` and asks again on [refresh]: when Home opens and
/// each time the player comes back from a game.
class HomeCubit extends Cubit<bool> {
  /// `hasGameToContinue` is a plain function rather than the game feature's
  /// use case, because features may not import each other. The composition
  /// root wires it to `HasGameToContinue`.
  HomeCubit({required this._hasGameToContinue}) : super(false);

  final Future<bool> Function() _hasGameToContinue;

  /// Asks again whether there is a saved game to continue.
  Future<void> refresh() async {
    final canContinue = await _hasGameToContinue();
    // Home may have closed while storage answered.
    if (!isClosed) emit(canContinue);
  }
}
