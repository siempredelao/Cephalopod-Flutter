import 'package:cephalopod/core/l10n/l10n.dart';

/// Words how far into How to play the screen is, for screen readers:
/// "Step 2 of 6", counting steps from 1, in the language on screen.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class TutorialProgressTextMapper {
  const TutorialProgressTextMapper();

  /// The words for [currentStep], counted from 0, out of [stepCount].
  String map(
    AppLocalizations l10n, {
    required int currentStep,
    required int stepCount,
  }) {
    return l10n.howToPlayProgress(currentStep + 1, stepCount);
  }
}
