import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/player_text_mapper.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod/features/home/presentation/models/saved_game_ui.dart';

/// Words the Continue card of the saved game, in the language on screen: who
/// the person plays, whose turn it is and how many dice each side has, and
/// what a screen reader says for all of it.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class SavedGameTextMapper {
  const SavedGameTextMapper({
    this._playerTextMapper = const PlayerTextMapper(),
  });

  final PlayerTextMapper _playerTextMapper;

  /// "vs a friend", or "vs Computer · Hard".
  String opponentOf(SavedGameUi game, AppLocalizations l10n) {
    return switch (game.computerLevel) {
      null => l10n.homeContinueFriend,
      final level => l10n.homeContinueComputer(_levelName(level, l10n)),
    };
  }

  /// Whose turn it is and each side's dice, Player 1's first: "Your turn ·
  /// you 5, computer 5".
  String detailsOf(SavedGameUi game, AppLocalizations l10n) {
    return l10n.homeContinueDetails(
      _turnOf(game, l10n),
      l10n.homeContinueTally(
        _diceOf(game.black, l10n),
        _diceOf(game.white, l10n),
      ),
    );
  }

  /// What a screen reader says for the card: "Continue. vs Computer · Hard.
  /// Your turn. You: 5 dice. Computer: 5 dice."
  String spokenOf(SavedGameUi game, AppLocalizations l10n) {
    String sideOf(SideSummary side) =>
        l10n.gameTallySide(_nameOf(side.side, l10n), side.dice);
    return l10n.homeContinueSpoken(
      l10n.homeContinue,
      opponentOf(game, l10n),
      _turnOf(game, l10n),
      l10n.gameTallySpoken(sideOf(game.black), sideOf(game.white)),
    );
  }

  String _levelName(ComputerLevel level, AppLocalizations l10n) {
    return switch (level) {
      ComputerLevel.easy => l10n.newGameEasy,
      ComputerLevel.medium => l10n.newGameMedium,
      ComputerLevel.hard => l10n.newGameHard,
    };
  }

  /// The turn of the side that is to move.
  String _turnOf(SavedGameUi game, AppLocalizations l10n) {
    final mover = game.black.toMove ? game.black.side : game.white.side;
    return switch (mover.role) {
      RoleUi.person => l10n.homeContinueTurnPerson,
      RoleUi.computer => l10n.homeContinueTurnComputer,
      RoleUi.player => l10n.homeContinueTurnPlayer(
        _playerTextMapper.map(mover.player, l10n),
      ),
    };
  }

  String _diceOf(SideSummary summary, AppLocalizations l10n) {
    final SideSummary(:side, :dice) = summary;
    return switch (side.role) {
      RoleUi.person => l10n.homeContinueDiceYou(dice),
      RoleUi.computer => l10n.homeContinueDiceComputer(dice),
      RoleUi.player => l10n.homeContinueDicePlayer(
        _playerTextMapper.map(side.player, l10n),
        dice,
      ),
    };
  }

  /// "Player 1", "You" or "Computer".
  String _nameOf(SideUi side, AppLocalizations l10n) => switch (side.role) {
    RoleUi.player => _playerTextMapper.map(side.player, l10n),
    RoleUi.person => l10n.gameTallyYou,
    RoleUi.computer => l10n.gameTallyComputer,
  };
}
