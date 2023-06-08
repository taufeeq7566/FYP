import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class Checkpoint {
  final String name;
  final double latitude;
  final double longitude;

  Checkpoint({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
  
    @override
  String toString() {
    return 'Checkpoint(name: $name, latitude: $latitude, longitude: $longitude)';
  }
}
class DistanceScreen extends StatefulWidget {
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
  List<Checkpoint> checkpoints = [];
  List<double> distances = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startDistanceUpdates();
    _retrieveCheckpoints();
  }

  @override
  void dispose() {
    _stopDistanceUpdates();
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
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _getCurrentLocation();
      _calculateDistance();
    });
  }

  void _stopDistanceUpdates() {
    _timer.cancel();
  }

  void _retrieveCheckpoints() {
    _databaseReference.once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<Checkpoint> retrievedCheckpoints = [];

        data.forEach((key, value) {
          String name = value['name'];
          double latitude = value['latitude'];
          double longitude = value['longitude'];

          retrievedCheckpoints.add(Checkpoint(
            name: name,
            latitude: latitude,
            longitude: longitude,
          ));
        });

        setState(() {
          checkpoints = retrievedCheckpoints;
        });

        print('Checkpoints: $checkpoints'); // Print the list of checkpoints
      }
    }).catchError((error) {
      print("Failed to fetch checkpoints: $error");
    });
  }

  void _calculateDistance() {
    List<double> updatedDistances = []; // Create a new list to store the updated distances

    checkpoints.forEach((checkpoint) {
      double distance = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        checkpoint.latitude,
        checkpoint.longitude,
      );

      String formattedDistance =
          distance.toStringAsFixed(2); // Format distance to two decimal places
      updatedDistances.add(distance); // Add the distance to the new list
      print('Distance to ${checkpoint.name}: $formattedDistance meters');

      // Check if the user is within the geofence radius (e.g., 20 meters)
      if (distance <= 20) {
        // User is within the geofence, perform desired actions (e.g., show a notification)
        print('User is within the geofence of ${checkpoint.name}');
      }
    });

    setState(() {
      distances = updatedDistances; // Update the distances list with the new distances
    });
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
          if (checkpoints.isEmpty)
            Text(
              'No Checkpoints Available',
              style: TextStyle(fontSize: 16),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: checkpoints.length,
              itemBuilder: (context, index) {
                final distance = distances.length > index ? distances[index].toStringAsFixed(2) : 'N/A';
                return ListTile(
                  title: Text(
                    checkpoints[index].name,
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Distance: $distance meters',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
        ],
      ),
    ),
  );
}
}


