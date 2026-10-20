/// The outcome of an operation that can fail as part of normal use: an [Ok]
/// with a value or an [Err] with the reason.
///
/// Callers handle both with an exhaustive `switch`:
///
/// ```dart
/// switch (rules.apply(state, move)) {
///   case Ok(:final value): show(value);
///   case Err(:final error): explain(error);
/// }
/// ```
sealed class Result<T, E> {
  const Result();
}

/// A successful [Result] holding [value].
final class Ok<T, E> extends Result<T, E> {
  /// Wraps the successful [value].
  const Ok(this.value);

  /// The successful value.
  final T value;
}

/// A failed [Result] holding [error].
final class Err<T, E> extends Result<T, E> {
  /// Wraps the reason for the failure, [error].
  const Err(this.error);

  /// Why the operation failed.
  final E error;
}
