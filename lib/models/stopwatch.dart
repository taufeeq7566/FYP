
import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchModel extends ChangeNotifier {
  Stopwatch _stopwatch = Stopwatch();
  Duration _elapsedTime = Duration.zero;

  StopwatchModel() {
    _startStopwatch();
  }

  Duration get elapsedTime => _elapsedTime;

  void _startStopwatch() {
    _stopwatch.start();
    Timer.periodic(Duration(milliseconds: 10), (_) {
      _elapsedTime = _stopwatch.elapsed;
      notifyListeners();
    });
  }

  void stopStopwatch() {
    _stopwatch.stop();
  }
}
