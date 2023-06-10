import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DistanceScreen extends StatefulWidget {
  final List<DistanceCheckpoint> checkpoints;
  final String userEmail;
  final Function(String) onRaceFinished;

  DistanceScreen({
    required this.checkpoints,
    required this.userEmail,
    required this.onRaceFinished,
  });

  @override
  _DistanceScreenState createState() => _DistanceScreenState();
}

class _DistanceScreenState extends State<DistanceScreen> {
  late Position _currentPosition = Position(
    latitude: 0,
    longitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');
  List<DistanceCheckpoint> checkpoints = [];
  List<double> distances = [];
  Timer? _timer;
  late Stopwatch _stopwatch;
  bool _isRaceFinished = false;
  String _userFullName = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startDistanceUpdates();
    _retrieveCheckpoints();
    _stopwatch = Stopwatch();
    _retrieveFullName();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
      setState(() {
        _currentPosition = position;
  });
    }
  

  void _startDistanceUpdates() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(milliseconds: 1), (_) {
        _getCurrentLocation();
        _calculateDistance();
      });
    }
  }

  void _stopDistanceUpdates() {
    _timer?.cancel();
  }

  void _retrieveCheckpoints() {
    _databaseReference.once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<DistanceCheckpoint> retrievedCheckpoints = [];

        data.forEach((key, value) {
          String name = value['name'];
          double latitude = value['latitude'];
          double longitude = value['longitude'];

          retrievedCheckpoints.add(DistanceCheckpoint(
            name: name,
            latitude: latitude,
            longitude: longitude,
          ));
        });

        retrievedCheckpoints.sort((a, b) => a.name.compareTo(b.name));

        setState(() {
          checkpoints = retrievedCheckpoints;
        });
      }
    }).catchError((error) {
      print("Failed to fetch checkpoints: $error");
    });
  }

  void _calculateDistance() {
    List<double> updatedDistances = List<double>.filled(checkpoints.length, 0.0);

    for (int i = 0; i < checkpoints.length; i++) {
      DistanceCheckpoint checkpoint = checkpoints[i];
      double distance = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        checkpoint.latitude,
        checkpoint.longitude,
      );

      String formattedDistance = distance.toStringAsFixed(2);
      updatedDistances[i] = distance;

      print('Distance to ${checkpoint.name}: $formattedDistance meters');

      if (distance <= 7 && !_isRaceFinished) {
        print('User is within the geofence of ${checkpoint.name}');

        if (checkpoint.name == 'Starting Line') {
          _startRace();
        } else if (checkpoint.name == 'Finish Line') {
          _stopRace();
          _uploadLeaderboard();
        } else {
          setState(() {
            // Update the stopwatch time for the current checkpoint
            checkpoint.stopwatchTime = _stopwatch.elapsed;
          });
        }
      }
    }

    setState(() {
      distances = updatedDistances;
    });
  }

void _uploadLeaderboard() {
  DatabaseReference leaderboardRef =
      FirebaseDatabase.instance.reference().child('leaderboard');

  for (int i = 0; i < checkpoints.length; i++) {
    DistanceCheckpoint checkpoint = checkpoints[i];
    Duration? stopwatchTime = checkpoint.stopwatchTime;

    if (stopwatchTime != null) {
      String formattedStopwatchTime = _formatDuration(stopwatchTime);
      String checkpointKey = 'checkpoint${i + 1}';

      Map<String, String> leaderboardData = {
        checkpointKey: formattedStopwatchTime,
      };

      leaderboardRef.child(_userFullName).update(leaderboardData).then((_) {
        print('Leaderboard data uploaded for $checkpointKey');
      }).catchError((error) {
        print('Failed to upload leaderboard data for $checkpointKey: $error');
      });
    }
  }
}



  void _startRace() {
    setState(() {
      _isRaceFinished = false;
      _stopwatch.start();
    });
  }

  void _stopRace() {
    widget.onRaceFinished(widget.userEmail);
    setState(() {
      _isRaceFinished = true;
      _stopwatch.stop();
    });
  }

  void _retrieveFullName() {
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users');

    userRef.child(widget.userEmail).once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        String? fullName = snapshot.value as String?;
        if (fullName != null) {
          setState(() {
            _userFullName = fullName;
          });
        }
      }
    }).catchError((error) {
      print("Failed to fetch user's full name: $error");
    });
  }

  String _formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String milliseconds =
        (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return '$minutes:$seconds:$milliseconds';
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Location:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Latitude: ${_currentPosition.latitude}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Longitude: ${_currentPosition.longitude}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (_isRaceFinished)
              Text(
                'Race Finished',
                style: TextStyle(fontSize: 18),
              )
            else
              Column(
                children: [
                  Text(
                    'Race in progress',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Time: ${_formatDuration(_stopwatch.elapsed)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Text(
              'Distances to Checkpoints:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            for (int i = 0; i < checkpoints.length; i++)
              Column(
                children: [
                  Text(
                    '${checkpoints[i].name}: ${distances[i].toStringAsFixed(2)} meters',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (checkpoints[i].stopwatchTime != null)
                    Text(
                      'Time: ${_formatDuration(checkpoints[i].stopwatchTime!)}',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class DistanceCheckpoint {
  final String name;
  final double latitude;
  final double longitude;
  Duration? stopwatchTime;

  DistanceCheckpoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.stopwatchTime,
  });
}
