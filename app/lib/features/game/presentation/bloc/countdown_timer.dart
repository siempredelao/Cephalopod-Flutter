import 'dart:async';

/// A wait, whose length is given each time it is started, which can be
/// cancelled and waited for.
///
/// Starting it again restarts the wait. A wait of zero never runs, so
/// [isActive] stays `false` and there is nothing to wait for.
class CountdownTimer {
  Timer? _timer;
  Completer<void>? _running;

  /// Whether a wait has started and neither ended nor been cancelled.
  bool get isActive => _running != null;

  /// Completes when the wait ends, or is cancelled, and at once when there
  /// is none.
  Future<void> get done => _running?.future ?? Future<void>.value();

  /// Starts a wait of [duration], replacing one that is running.
  void start(Duration duration) {
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
