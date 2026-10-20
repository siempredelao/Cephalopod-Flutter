import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Test shortcuts that unwrap a [Result] or fail the test.
extension ResultExpectations<T, E> on Result<T, E> {
  /// The value of an [Ok]. Throws, failing the test, for an [Err].
  T get valueOrFail => switch (this) {
    Ok(:final value) => value,
    Err(:final error) => throw StateError('Expected Ok, got Err: $error'),
  };

  /// The error of an [Err]. Throws, failing the test, for an [Ok].
  E get errorOrFail => switch (this) {
    Ok(:final value) => throw StateError('Expected Err, got Ok: $value'),
    Err(:final error) => error,
  };
}
