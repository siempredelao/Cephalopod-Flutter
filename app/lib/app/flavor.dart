/// Build flavor, chosen by the entry point: `lib/main.dart` runs
/// [Flavor.prod] and `lib/main_dev.dart` runs [Flavor.dev].
enum Flavor {
  /// Local development: shows the debug banner.
  dev,

  /// The build that ships.
  prod,
}
