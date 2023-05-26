import 'dart:async';

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
  _databaseReference.once().then((DataSnapshot snapshot) {
    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        double latitude = value['latitude'];
        double longitude = value['longitude'];
        String name = value['name'];

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(key),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: name),
            ),
          );
        });
      });
    }
  } as FutureOr Function(DatabaseEvent value));
}



  void _addCheckpoint() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController latitudeController = TextEditingController();
        TextEditingController longitudeController = TextEditingController();

        return AlertDialog(
          title: Text('Add Checkpoint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: latitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                double latitude = double.tryParse(latitudeController.text) ?? 0.0;
                double longitude = double.tryParse(longitudeController.text) ?? 0.0;

                if (name.isNotEmpty && latitude != 0.0 && longitude != 0.0) {
                  _saveCheckpoint(name, latitude, longitude);
                  Navigator.pop(context);
                } else {
                  // Show an error message or handle invalid input
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveCheckpoint(String name, double latitude, double longitude) {
    DatabaseReference newCheckpointRef = _databaseReference.push();
    newCheckpointRef.set({
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(newCheckpointRef.key!),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: name),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkpoint Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              _showCheckpointList();
            },
          ),
        ],
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
          _addCheckpoint();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showCheckpointList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkpoints'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _markers.length,
              itemBuilder: (BuildContext context, int index) {
                Marker marker = _markers.elementAt(index);
                return ListTile(
                  title: Text(marker.infoWindow.title ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteCheckpoint(marker);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _deleteCheckpoint(Marker marker) {
    String markerId = marker.markerId.value;
    _markers.remove(marker);
    _databaseReference.child(markerId).remove();
  }
}
