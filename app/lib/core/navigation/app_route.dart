/// Names of the app's routes. Screens navigate by name, never by path, so a
/// path can change in one place: `app/router.dart`.
enum AppRoute {
  /// The start screen.
  home,

  /// A game between two players taking turns on one device.
  game,

  /// Credits and a link to the official rule sheet.
  about,
}
