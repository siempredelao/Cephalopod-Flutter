/// The finished games after which the app asks for a review: the third,
/// when the person has seen enough of the game to have an opinion, and once
/// more at the tenth. Never more, as Google limits the sheet anyway.
const Set<int> _gamesToAskAfter = {3, 10};

/// Whether [finishedGames], the number of games finished so far, including
/// the one that just ended, is a time to ask for a review.
bool isTimeToAskForReview(int finishedGames) {
  return _gamesToAskAfter.contains(finishedGames);
}
