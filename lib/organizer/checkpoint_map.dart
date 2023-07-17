import 'dart:async';

import 'package:checkpoint_geofence/Forms/add_checkpoint.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckpointMapScreen extends StatefulWidget {
  @override
  _CheckpointMapScreenState createState() => _CheckpointMapScreenState();
}

class _CheckpointMapScreenState extends State<CheckpointMapScreen> {
  final Set<Marker> _markers = {};
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');

  final Completer<GoogleMapController> _mapController = Completer();
  String _mapTheme = '';

  List<String> _themeOptions = [
    'Standard',
    'Retro',
    'Dark',
    'Aubergine',
  ];
  String _selectedTheme = 'Standard';

  @override
  void initState() {
    super.initState();
    _retrieveCheckpoints();
    _loadMapTheme();
  }

  void _loadMapTheme() async {
    _mapTheme = await DefaultAssetBundle.of(context)
        .loadString('lib/assets/maptheme/standard_mode.json');
    _updateMapTheme();
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
                draggable: true, // Make the marker draggable
                onDragEnd: (LatLng newPosition) {
                  _showConfirmationDialog(key, name, newPosition);
                },
              ),
            );
          });
        });
      }
    });
  }

  void _onThemeChanged(String? value) async {
    if (value != null) {
      setState(() {
        _selectedTheme = value;
      });

      String themeFilePath = '';

      switch (value) {
        case 'Retro':
          themeFilePath = 'lib/assets/maptheme/retro_mode.json';
          break;
        case 'Standard':
          themeFilePath = 'lib/assets/maptheme/standard_mode.json';
          break;
        case 'Dark':
          themeFilePath = 'lib/assets/maptheme/dark_mode.json';
          break;
        case 'Aubergine':
          themeFilePath = 'lib/assets/maptheme/aubergine_mode.json';
          break;
      }

      print('Loading theme file: $themeFilePath');

      _mapTheme =
          await DefaultAssetBundle.of(context).loadString(themeFilePath);
      print('Loaded theme: $value');

      _updateMapTheme();
    }
  }

  void _updateMapTheme() async {
    final GoogleMapController controller = await _mapController.future;
    controller.setMapStyle(_mapTheme);
  }

  Future<void> _getUserLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final GoogleMapController controller = await _mapController.future;
    controller.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        18.0,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkpoint Map'),
        backgroundColor: Color(0xFFFC766A),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTheme,
                onChanged: _onThemeChanged,
                dropdownColor: Color(0xFFFC766A),
                items: _themeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Image.asset(
                          'lib/assets/picture_assets/theme.png',
                          width: 31,
                          height: 31,
                        ),
                        SizedBox(width: 5),
                        Text(
                          value,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(2.273664, 102.446846),
          zoom: 18.0,
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            left: 50.0,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: _showCheckpointList,
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFC766A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Image.asset(
                  'lib/assets/picture_assets/listButton.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80.0,
            left: 50.0,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
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
                            draggable: true,
                            onDragEnd: (LatLng newPosition) {
                              _showConfirmationDialog(value['key'], name, newPosition);
                            },
                          ),
                        );
                      });
                    }
                  });
                  dispose();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFC766A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Image.asset(
                  'lib/assets/picture_assets/addButton.png',
                  width: 40,
                  height: 40,
                ),
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
                        
                        _showDeleteConfirmationDialog(marker);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editCheckpoint(marker);
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
  final TextEditingController nameController =
      TextEditingController(text: marker.infoWindow.title ?? '');
  final TextEditingController latitudeController =
      TextEditingController(text: marker.position.latitude.toString());
  final TextEditingController longitudeController =
      TextEditingController(text: marker.position.longitude.toString());

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
            onPressed: () {
              _showSaveConfirmationDialog(marker, nameController.text,
                  latitudeController.text, longitudeController.text);
            },
          ),
        ],
      );
    },
  );
}

void _showDeleteConfirmationDialog(Marker marker) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete this checkpoint?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              _deleteCheckpoint(marker).then((_) {
                // Close the confirmation dialog
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                // Show a new dialog with the updated checkpoint list
                _showCheckpointList();
              });
            },
          ),
        ],
      );
    },
  );
}



void _showSaveConfirmationDialog(Marker marker, String newName, String newLatitude, String newLongitude) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to save the changes?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              double latitude = double.parse(newLatitude);
              double longitude = double.parse(newLongitude);
              _updateCheckpoint(marker, newName, latitude, longitude);
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CheckpointMapScreen()),
              );
            },
          ),
        ],
      );
    },
  );
}



  void _updateCheckpoint(
      Marker marker, String newName, double newLatitude, double newLongitude) {
    setState(() {
      // Remove the existing marker
      _markers.remove(marker);

      // Create a new marker with updated information
      Marker updatedMarker = Marker(
        markerId: marker.markerId,
        position: LatLng(newLatitude, newLongitude),
        infoWindow: InfoWindow(title: newName),
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          _showConfirmationDialog(marker.markerId.value, newName, newPosition);
        },
      );

      // Add the updated marker back to the set
      _markers.add(updatedMarker);
    });
  }

  Future<void> _deleteCheckpoint(Marker marker) async {
    String checkpointKey = marker.markerId.value;

    // Remove the checkpoint from the real-time database
    await _databaseReference.child(checkpointKey).remove();

    setState(() {
      _markers.remove(marker);
    });
  }

  void _showConfirmationDialog(
      String checkpointKey, String checkpointName, LatLng newPosition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to move the checkpoint to the new location?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Move'),
              onPressed: () async {
                await _databaseReference.child(checkpointKey).update({
                  'latitude': newPosition.latitude,
                  'longitude': newPosition.longitude,
                });

                Navigator.of(context).pop(); // Close the dialog box

                setState(() {
                  _updateCheckpoint(
                      _markers.firstWhere((marker) => marker.markerId.value == checkpointKey),
                      checkpointName,
                      newPosition.latitude,
                      newPosition.longitude);
                  _retrieveCheckpoints();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
