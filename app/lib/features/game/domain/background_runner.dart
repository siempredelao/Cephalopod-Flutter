import 'dart:async';

/// Runs `callback(message)` away from the UI, so a long computation does not
/// freeze the screen, and gives back its result.
///
/// The domain cannot import Flutter, so the game module provides one:
/// Flutter's `compute`, which runs it on another isolate where there is one
/// (not on the web). The callback and its message are copied to that
/// isolate, so they must hold only plain Dart objects.
typedef BackgroundRunner = Future<R> Function<M, R>(
  FutureOr<R> Function(M message) callback,
  M message,
);
