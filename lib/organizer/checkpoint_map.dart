import 'package:checkpoint_geofence/organizer/add_checkpoint.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckpointMapScreen extends StatefulWidget {
  @override
  _CheckpointMapScreenState createState() => _CheckpointMapScreenState();
}

class _CheckpointMapScreenState extends State<CheckpointMapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');

  @override
  void initState() {
    super.initState();
    _retrieveCheckpoints();
  }

  void _retrieveCheckpoints() {
    _databaseReference.once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          double latitude = value['latitude'];
          double longitude = value['longitude'];

          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(key),
                position: LatLng(latitude, longitude),
              ),
            );
          });
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkpoint Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 15.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCheckpointScreen()),
          ).then((value) {
            if (value != null) {
              // Add the new checkpoint marker based on the value returned
              setState(() {
                _markers.add(
                  Marker(
                    markerId: MarkerId(value['key']),
                    position: LatLng(value['latitude'], value['longitude']),
                  ),
                );
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
