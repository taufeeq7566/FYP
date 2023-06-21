import 'dart:async';

class StopwatchManager {
  static final StopwatchManager _instance = StopwatchManager._internal();

  factory StopwatchManager() {
    return _instance;
  }

  Stopwatch _stopwatch = Stopwatch();
  StreamController<Duration> _stopwatchController = StreamController<Duration>.broadcast();

  Stream<Duration> get stopwatchStream => _stopwatchController.stream;

  StopwatchManager._internal();

  void startStopwatch() {
    _stopwatch.start();
    _startTimer();
  }

  void stopStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
  }

  void _startTimer() {
    Timer.periodic(const Duration(milliseconds: 1), (_) {
      if (_stopwatch.isRunning) {
        _stopwatchController.add(_stopwatch.elapsed);
      }
    });
  }

  void dispose() {
    _stopwatchController.close();
  }
}
