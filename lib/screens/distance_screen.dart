import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:checkpoint_geofence/models/checkpoint.dart';

class DistanceScreen extends StatefulWidget {
  const DistanceScreen({Key? key}) : super(key: key);

  @override
  _DistanceScreenState createState() => _DistanceScreenState();
}

class _DistanceScreenState extends State<DistanceScreen> {
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });
  }

void _calculateDistance() {
  for (Checkpoint checkpoint in checkpoints) {
    double distance = Geolocator.distanceBetween(
      _currentPosition.latitude,
      _currentPosition.longitude,
      checkpoint.latitude,
      checkpoint.longitude,
    );

    print('Distance to ${checkpoint.name}: $distance meters');

    // Check if the user is within the geofence radius (e.g., 50 meters)
    if (distance <= 50) {
      // User is within the geofence, perform desired actions (e.g., show a notification)
      print('User is within the geofence of ${checkpoint.name}');
    }
  }
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
            ElevatedButton(
              onPressed: _calculateDistance,
              child: Text('Calculate Distance'),
            ),
          ],
        ),
      ),
    );
  }
}


