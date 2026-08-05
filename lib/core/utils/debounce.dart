import 'dart:async';

/// Simple debounce for search and other high-frequency UI events.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 200)});

  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
