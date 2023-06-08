import 'package:checkpoint_geofence/organizer/add_checkpoint.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
          });
        });
      }
    });
  }

  Future<void> _getUserLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    mapController.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        18.0,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getUserLocation();
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
          target: LatLng(2.273664,102.446846),
          zoom: 18.0,
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                heroTag: 'listButton',
                onPressed: () {
                  _showCheckpointList();
                },
                child: Icon(Icons.list),
              ),
            ),
          ),
          Positioned(
            bottom: 80.0,
            left: 16.0,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                heroTag: 'addButton',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCheckpointScreen()),
                  ).then((value) {
                    if (value != null) {
                      // Add the new checkpoint marker based on the value returned
                      setState(() {
                        String name = value['name'];
                        double latitude = value['latitude'];
                        double longitude = value['longitude'];
                        _markers.add(
                          Marker(
                            markerId: MarkerId(value['key']),
                            position: LatLng(latitude, longitude),
                            infoWindow: InfoWindow(title: name),
                          ),
                        );
                      });
                    }
                  });
                },
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

void _showCheckpointList() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Available Checkpoints'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: _markers.length,
            itemBuilder: (BuildContext context, int index) {
              final marker = _markers.elementAt(index);
              return ListTile(
                title: Text(marker.infoWindow.title ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteCheckpoint(marker);
                        Navigator.of(context).pop();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Future.delayed(Duration.zero, () {
                          _editCheckpoint(marker);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


void _editCheckpoint(Marker marker) {
  final TextEditingController nameController = TextEditingController(text: marker.infoWindow.title ?? '');
  final TextEditingController latitudeController = TextEditingController(text: marker.position.latitude.toString());
  final TextEditingController longitudeController = TextEditingController(text: marker.position.longitude.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Checkpoint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(
                labelText: 'Latitude',
              ),
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(
                labelText: 'Longitude',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              String newName = nameController.text;
              double newLatitude = double.tryParse(latitudeController.text) ?? 0.0;
              double newLongitude = double.tryParse(longitudeController.text) ?? 0.0;

              if (newName.isNotEmpty) {
                await _databaseReference.child(marker.markerId.value).update({
                  'name': newName,
                  'latitude': newLatitude,
                  'longitude': newLongitude,
                });
                
                Navigator.of(context).pop(); // Close the dialog box

                setState(() {
                  _updateCheckpoint(marker,newName,newLatitude,newLongitude);
                  _retrieveCheckpoints();
                });
              }
            },
          ),
        ],
      );
    },
  );
}





  void _updateCheckpoint(Marker marker, String newName, double newLatitude, double newLongitude) {
    setState(() {
      // Remove the existing marker
      _markers.remove(marker);

      // Create a new marker with updated information
      Marker updatedMarker = Marker(
        markerId: marker.markerId,
        position: LatLng(newLatitude, newLongitude),
        infoWindow: InfoWindow(title: newName),
      );

      // Add the updated marker back to the set
      _markers.add(updatedMarker);
    });
  }

void _deleteCheckpoint(Marker marker) async {
  String checkpointKey = marker.markerId.value;

  // Remove the checkpoint from the real-time database
  await _databaseReference.child(checkpointKey).remove();

  setState(() {
    _markers.remove(marker);
  });
}
}
