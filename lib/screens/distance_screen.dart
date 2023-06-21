import 'dart:async';

import 'package:checkpoint_geofence/models/stopwatch.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DistanceScreen extends StatefulWidget {
  final List<DistanceCheckpoint> checkpoints;
  final String userEmail;
  final StopwatchManager _stopwatchManager = StopwatchManager();


  DistanceScreen({required this.checkpoints, required this.userEmail});

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
  List<Duration> checkpointTimes = [];
  String _userFullName = '';
  Stopwatch stopwatch = Stopwatch();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _retrieveCheckpoints();
    _getCurrentLocation();
    _retrieveFullName();
    _timer = Timer.periodic(Duration(seconds: 2), (_) => _calculateDistance());
  }

  @override
  void dispose() {
    _timer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (this.mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
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
            stopwatchTime: null,
          ));
        });

        // Move the "Starting Line" checkpoint to the first position
        int startingLineIndex = retrievedCheckpoints.indexWhere((checkpoint) => checkpoint.name == 'Starting Line');
        if (startingLineIndex != -1) {
          DistanceCheckpoint startingLineCheckpoint = retrievedCheckpoints.removeAt(startingLineIndex);
          retrievedCheckpoints.insert(0, startingLineCheckpoint);
        }

        // Move the "Finish Line" checkpoint to the last position
        int finishLineIndex = retrievedCheckpoints.indexWhere((checkpoint) => checkpoint.name == 'Finish Line');
        if (finishLineIndex != -1) {
          DistanceCheckpoint finishLineCheckpoint = retrievedCheckpoints.removeAt(finishLineIndex);
          retrievedCheckpoints.add(finishLineCheckpoint);
        }

        if (this.mounted) {
          setState(() {
            checkpoints = retrievedCheckpoints;
          });
        }
      }
    }).catchError((error) {
      print("Failed to fetch checkpoints: $error");
    });
  }

  void _calculateDistance() {
    List<double> updatedDistances = List<double>.filled(checkpoints.length, 0.0);
    List<Duration> updatedCheckpointTimes = List<Duration>.from(checkpointTimes);

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

      if (distance <= 20) {
        print('User is within the geofence of ${checkpoint.name}');

        if (checkpoint.name == 'Starting Line') {
          _startRace();
        }

        if (checkpoint.stopwatchTime == null) {
          DistanceCheckpoint updatedCheckpoint = DistanceCheckpoint(
            name: checkpoint.name,
            latitude: checkpoint.latitude,
            longitude: checkpoint.longitude,
            stopwatchTime: stopwatch.elapsed,
          );
          checkpoints[i] = updatedCheckpoint; // Update the checkpoint in the list

          updatedCheckpointTimes.add(updatedCheckpoint.stopwatchTime!);
          _uploadCheckpointTime(updatedCheckpoint.stopwatchTime!);
        }
      }
    }

    if (this.mounted) {
      setState(() {
        distances = updatedDistances;
        checkpointTimes = updatedCheckpointTimes;
      });
    }
  }

  void _uploadCheckpointTime(Duration? time) {
    if (time == null) {
      return; // Skip uploading if the duration is null
    }

    DatabaseReference leaderboardRef =
        FirebaseDatabase.instance.reference().child('leaderboard');

    Map<String, String> checkpointData = {};

    for (int i = 0; i < checkpoints.length; i++) {
      DistanceCheckpoint checkpoint = checkpoints[i];
      Duration? checkpointTime = checkpoint.stopwatchTime;

      if (checkpointTime != null) {
        String formattedCheckpointTime = _formatDuration(checkpointTime);
        String checkpointKey = 'checkpoint${i + 1}';

        checkpointData[checkpointKey] = formattedCheckpointTime;
      }
    }

    leaderboardRef
        .child(_userFullName)
        .child('checkpoints')
        .set(checkpointData)
        .then((_) {
      print('Checkpoint times uploaded successfully');
    }).catchError((error) {
      print('Failed to upload checkpoint times: $error');
    });
  }

  void _startRace() {
    if (this.mounted) {
      setState(() {
        checkpointTimes = [];
        stopwatch.start();
      });
    }
  }

  void _stopRace() {
    if (this.mounted) {
      setState(() {
        stopwatch.stop();
      });
    }
  }

  void _retrieveFullName() {
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users');

    Query query = userRef
        .orderByChild('email')
        .equalTo(widget.userEmail)
        .limitToFirst(1);

    query.once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          String userId = data.keys.first;
          String? fullName = data[userId]['fullname'] as String?;
          if (fullName != null) {
            if (this.mounted) {
              setState(() {
                _userFullName = fullName;
              });
            }
            print('Full name retrieved successfully: $_userFullName');
          } else {
            print('Full name is null');
          }
        } else {
          print('Data is null');
        }
      } else {
        print('Snapshot value is null');
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
    String elapsedFormattedTime = _formatDuration(stopwatch.elapsed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Elapsed Time:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              elapsedFormattedTime,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
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
            Text(
              'Email:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              widget.userEmail,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Full Name:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              _userFullName,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Distances to Checkpoints:',
              style: TextStyle(fontSize: 18),
            ),
            if (checkpoints.isNotEmpty && distances.isNotEmpty)
              for (int i = 0; i < checkpoints.length; i++) ...[
                SizedBox(height: 10),
                Text(
                  '${checkpoints[i].name}: ${distances[i].toStringAsFixed(2)} meters',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Elapsed Time: ${_formatDuration(checkpoints[i].stopwatchTime ?? stopwatch.elapsed)}',
                  style: TextStyle(fontSize: 14),
                ),
              ]
            else
              Container(
                child: Text(
                  'No checkpoints or distances available.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}

class DistanceCheckpoint {
  final String name;
  final double latitude;
  final double longitude;
  final Duration? stopwatchTime;

  DistanceCheckpoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.stopwatchTime,
  });
}
