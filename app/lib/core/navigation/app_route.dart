/// Names of the app's routes. Screens navigate by name, never by path, so a
/// path can change in one place: the module of the feature that owns it.
enum AppRoute {
  /// The start screen.
  home,

  /// Choosing who to play against, before a game starts.
  newGame,

  /// A game, against a friend on the same device or the computer.
  game,

  /// How to play, one rule per page with a board that shows it.
  howToPlay,

  /// The player's settings.
  settings,

  /// Credits and a link to the official rule sheet.
  about,
}
