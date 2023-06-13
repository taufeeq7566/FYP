import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SpectatorMapScreen extends StatefulWidget {
  @override
  _SpectatorMapScreenState createState() => _SpectatorMapScreenState();
}

class _SpectatorMapScreenState extends State<SpectatorMapScreen> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  final LatLng _center = const LatLng(2.273664, 102.446846); // Center coordinate
  final double _radius = 15.0; // Radius of the geofence in meters

  @override
  void initState() {
    super.initState();
    _fetchCheckpoints();
  }

void _fetchCheckpoints() {
  _databaseReference.once().then((event) {
    final snapshot = event.snapshot;
    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        String name = value['name']; // Get the checkpoint name
        double latitude = value['latitude'];
        double longitude = value['longitude'];

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(key),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: name), // Set the checkpoint name as the title
            ),
          );

          _circles.add(
            Circle(
              circleId: CircleId(key),
              center: LatLng(latitude, longitude),
              radius: _radius,
              strokeWidth: 2,
              strokeColor: Colors.blue,
              fillColor: Colors.blue.withOpacity(0.3),
            ),
          );
        });
      });
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spectator Map'),
      ),
      body: GoogleMap(
        markers: _markers,
        circles: _circles,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
      ),
    );
  }
}
