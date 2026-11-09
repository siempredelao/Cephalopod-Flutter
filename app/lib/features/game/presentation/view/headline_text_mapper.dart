import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_text_mapper.dart';

/// Puts the headline above the board into words, in the language on screen:
/// what the game waits for, or how it ended, winner first. Against the
/// computer, the person is "you".
///
/// A text mapper (docs/adr/0015): the bloc's mappers decide what the
/// headline means; this class only puts it into words.
final class HeadlineTextMapper {
  const HeadlineTextMapper({
    this._playerTextMapper = const PlayerTextMapper(),
  });

  final PlayerTextMapper _playerTextMapper;

  /// The words for [headline], such as "Player 2 wins 13 to 12".
  String map(HeadlineUi headline, AppLocalizations l10n) => switch (headline) {
    PlayerToMoveHeadline(:final player) => l10n.gameHeadlinePlayerToMove(
      _playerTextMapper.map(player, l10n),
    ),
    PersonToMoveHeadline() => l10n.gameHeadlinePersonToMove,
    ComputerToMoveHeadline() => l10n.gameHeadlineComputerToMove,
    PlayerWonHeadline(:final player, :final winnerDice, :final loserDice) =>
      l10n.gameHeadlinePlayerWon(
        _playerTextMapper.map(player, l10n),
        winnerDice,
        loserDice,
      ),
    PersonWonHeadline(:final winnerDice, :final loserDice) =>
      l10n.gameHeadlinePersonWon(winnerDice, loserDice),
    ComputerWonHeadline(:final winnerDice, :final loserDice) =>
      l10n.gameHeadlineComputerWon(winnerDice, loserDice),
  };
}
