import 'package:cephalopod/features/about/domain/models/app_version.dart';

/// Tells which version of the app is running, or `null` when it cannot be
/// known.
typedef AppVersionSource = Future<AppVersion?> Function();
