import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/types.dart';

/// shared_preferences storage that fails on every read and write. By
/// default it fails as the plugin does when the device's storage is broken
/// or full: with a [PlatformException].
///
/// Install it with `SharedPreferencesAsyncPlatform.instance =
/// FailingSharedPreferences();`.
final class FailingSharedPreferences extends InMemorySharedPreferencesAsync {
  /// Storage whose every call throws [failure], or a [PlatformException]
  /// when none is given. Pass an `Error` to play a bug instead.
  FailingSharedPreferences({Object? failure})
    : failure =
          failure ??
          PlatformException(
            code: 'storage-failed',
            message: 'The device storage failed',
          ),
      super.empty();

  /// What every call throws.
  final Object failure;

  @override
  Future<String?> getString(String key, SharedPreferencesOptions options) =>
      _fail();

  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) =>
      _fail();

  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) => _fail();

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) => _fail();

  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) => _fail();

  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) => _fail();

  @override
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) => _fail();

  Future<Never> _fail() async {
    Error.throwWithStackTrace(failure, StackTrace.current);
  }
}
