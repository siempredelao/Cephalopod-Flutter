import 'dart:async';

/// A wait of a set length, which can be started, cancelled and waited for.
///
/// Starting it again restarts the wait. With a [duration] of zero it never
/// runs, so [isActive] is always `false` and there is nothing to wait for.
class CountdownTimer {
  CountdownTimer(this.duration);

  /// How long the wait lasts once [start]ed.
  final Duration duration;

  Timer? _timer;
  Completer<void>? _running;

  /// Whether a wait has started and neither ended nor been cancelled.
  bool get isActive => _running != null;

  /// Completes when the wait ends, or is cancelled, and at once when there
  /// is none.
  Future<void> get done => _running?.future ?? Future<void>.value();

  /// Starts the wait, replacing one that is running.
  void start() {
    cancel();
    if (duration == Duration.zero) return;
    _running = Completer<void>();
    _timer = Timer(duration, cancel);
  }

  /// Ends the wait now, if there is one. Whoever waits for [done] goes on.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    final running = _running;
    _running = null;
    running?.complete();
  }
}
