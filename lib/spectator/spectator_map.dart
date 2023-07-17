import 'dart:async';

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

  final Completer<GoogleMapController> _controller = Completer();
  String mapTheme = '';

  List<String> themeOptions = [
    'Standard',
    'Retro',
    'Dark',
    'Aubergine',
  ];
  String selectedTheme = 'Standard';

  @override
  void initState() {
    super.initState();
    _fetchCheckpoints();
    DefaultAssetBundle.of(context)
        .loadString('lib/assets/maptheme/standard_mode.json')
        .then((value) {
      mapTheme = value;
    });
  }

  void _fetchCheckpoints() {
    _databaseReference.once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          String name = value['name']; // Get the checkpoint name
          double latitude = value['latitude'];
          double longitude = value['longitude'];

          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(key),
                position: LatLng(latitude, longitude),
                infoWindow:
                    InfoWindow(title: name), // Set the checkpoint name as the title
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

void _onThemeChanged(String? value) async {
  if (value != null) {
    setState(() {
      selectedTheme = value;
    });

    switch (value) {
      case 'Retro':
        // Load retro theme
        mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/retro_mode.json');
        break;
      case 'Standard':
        // Load normal theme
        mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/standard_mode.json');
        break;
      case 'Dark':
        // Load dark theme
        mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/dark_mode.json');
        break;
      case 'Aubergine':
        // Load aubergine theme
        mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/aubergine_mode.json');
        break;
    }

    _updateMapTheme();
  }
}

  void _updateMapTheme() async {
    final GoogleMapController controller = await _controller.future;
    controller.setMapStyle(mapTheme);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [

            Text(
              'Spectator Map',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFC766A),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedTheme,
                onChanged: _onThemeChanged,
                dropdownColor: Color(0xFFFC766A),
                items: themeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Image.asset(
                          'lib/assets/picture_assets/theme.png',
                          width: 31,
                          height: 31,
                        ),
                        SizedBox(width: 8),
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
        markers: _markers,
        circles: _circles,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _updateMapTheme();
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
      ),
    );
  }
}

