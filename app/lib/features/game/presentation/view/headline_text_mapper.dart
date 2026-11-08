import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_text_mapper.dart';

/// Puts the headline above the board into words: what the game waits for,
/// or how it ended, winner first. Against the computer, the person is "you".
///
/// A text mapper (docs/adr/0015): the bloc's mappers decide what the
/// headline means; this class only puts it into words.
final class HeadlineTextMapper {
  const HeadlineTextMapper({
    this._playerTextMapper = const PlayerTextMapper(),
  });

  final PlayerTextMapper _playerTextMapper;

  /// The words for [headline], such as "Player 2 wins 13 to 12".
  String map(HeadlineUi headline) => switch (headline) {
    PlayerToMoveHeadline(:final player) =>
      '${_playerTextMapper.map(player)} to move',
    PersonToMoveHeadline() => 'Your turn',
    ComputerToMoveHeadline() => 'The computer is thinking…',
    PlayerWonHeadline(:final player, :final winnerDice, :final loserDice) =>
      '${_playerTextMapper.map(player)} wins $winnerDice to $loserDice',
    PersonWonHeadline(:final winnerDice, :final loserDice) =>
      'You win $winnerDice to $loserDice',
    ComputerWonHeadline(:final winnerDice, :final loserDice) =>
      'The computer wins $winnerDice to $loserDice',
  };
}
