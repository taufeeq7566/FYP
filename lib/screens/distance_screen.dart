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

  print('Before retrieving full name');
  _retrieveFullName();
  print('After retrieving full name');
  }

  @override
  void dispose() {
    super.dispose();
    _stopDistanceUpdates();
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
  bool isRaceStarted = false;

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

    if (checkpoint.name == 'Starting Line' && distance <= 15 && !_isRaceFinished) {
      // Start the stopwatch
      _stopwatch.start();
      isRaceStarted = true;
    } else if (distance <= 15 && !_isRaceFinished) {
      // Update the stopwatch time for all checkpoints passed through
      checkpoint.stopwatchTime = _stopwatch.elapsed;
    }
  }

  setState(() {
    distances = updatedDistances;
  });

  _checkRaceFinished();
}





void _checkRaceFinished() {
  bool raceFinished = checkpoints
      .where((checkpoint) => checkpoint.name != 'Finish Line')
      .every((checkpoint) => checkpoint.stopwatchTime != null);

  if (raceFinished && !_isRaceFinished) {
    _isRaceFinished = true;
    _stopwatch.stop();
    String formattedTime = _formatDuration(_stopwatch.elapsed);
    widget.onRaceFinished(formattedTime);
    print('Race finished for user: $formattedTime');

    // Uncomment the following line if you want to show the stopwatch time under each checkpoint
    // after the race is finished.
    // setState(() {});

    return; // Exit the method after the race is finished
  }

  _calculateDistance();
}


  
String _formatDuration(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitMilliseconds = twoDigits((duration.inMilliseconds.remainder(1000) ~/ 10));

  return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds";
}



  void _retrieveFullName() {
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users');
    userRef.child('email').child(widget.userEmail).once().then((event) {

      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        String fullName = data['fullname'];

        setState(() {
          _userFullName = fullName;
        });
        print('Retrieved full name: $fullName');
      }
    }).catchError((error) {
      print("Failed to retrieve user's full name: $error");
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

        leaderboardRef
            .child(_userFullName)
            .update(leaderboardData)
            .then((_) {
          print('Leaderboard data uploaded for $checkpointKey');
        }).catchError((error) {
          print('Failed to upload leaderboard data for $checkpointKey: $error');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String raceStatus = _isRaceFinished ? 'Race Finished' : 'Race in progress';
    if (_isRaceFinished && checkpoints.any((checkpoint) => checkpoint.stopwatchTime == null)) {
      raceStatus = 'Race in progress';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Distance Race'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text(
      'Checkpoints:',
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8.0),
    Text(
      'Stopwatch: ${_formatDuration(_stopwatch.elapsed)}',
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8.0),  // Add some spacing
    Text(
      'User: $_userFullName',
      style: TextStyle(
        fontSize: 16.0,
      ),
    ),
    SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: checkpoints.length,
                itemBuilder: (context, index) {
                  DistanceCheckpoint checkpoint = checkpoints[index];
                  double distance = distances.isNotEmpty ? distances[index] : 0.0;

                  String formattedDistance = distance.toStringAsFixed(2);
                  String distanceText = 'Distance: $formattedDistance meters';

                  String stopwatchTimeText = checkpoint.stopwatchTime != null
                      ? 'Time: ${_formatDuration(checkpoint.stopwatchTime!)}'
                      : '';

                  return ListTile(
                    title: Text(checkpoint.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(distanceText),
                        Text(stopwatchTimeText),
                      ],
                    ),
                    trailing: Text(raceStatus),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_stopwatch.isRunning) {
            _stopwatch.stop();
          } else {
            _stopwatch.start();
          }
        },
        child: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
