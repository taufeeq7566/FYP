import 'dart:async';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SOSMap extends StatefulWidget {
  @override
  _SOSMapState createState() => _SOSMapState();
}

class _SOSMapState extends State<SOSMap> {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  String mapTheme = '';
  Set<Marker> _markers = {};

  final LatLng _center = const LatLng(2.273664, 102.446846);

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
    _retrieveSOSCoordinates();
    _loadMapTheme();

  }

  void _loadMapTheme() async {
    mapTheme = await DefaultAssetBundle.of(context).loadString('lib/assets/maptheme/standard_mode.json');
    _updateMapTheme();
  }

  void _retrieveSOSCoordinates() {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('sos');

    databaseReference.onValue.listen((event) {
      final _markers = event.snapshot.value as Map<dynamic, dynamic>?;
      _updateSOSMarkers(_markers);
    });
    _updateSOSMarkers(null);
  }

  Future<BitmapDescriptor> _createCustomMarker() async {
    final Uint8List markerIcon = await getBytesFromAsset(
        'lib/assets/picture_assets/emergency_marker.png', 100, 100);
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width, int height) async {
    final ByteData data = await rootBundle.load(path);
    final Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final frame = await codec.getNextFrame();
    final imageBytes = await frame.image.toByteData(format: ImageByteFormat.png);
    return imageBytes!.buffer.asUint8List();
  }

void _updateSOSMarkers(Map<dynamic, dynamic>? data) async {
  if (data == null) return;

  Set<Marker> markers = {};

  for (final entry in data.entries) {
    final key = entry.key;
    final value = entry.value;

    final latitude = value['latitude'];
    final longitude = value['longitude'];

    final marker = Marker(
      markerId: MarkerId(key),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: 'SOS Location',
        snippet: 'Latitude: $latitude, Longitude: $longitude',
      ),
      icon: await _createCustomMarker(),
      onTap: () => _deleteSOSMarker(key),
    );

    markers.add(marker);
  }

  setState(() {
    _markers = markers;
  });
}


void _updateMapTheme() async {
  final GoogleMapController controller = await _controller.future;
  if (controller != null) {
    controller.setMapStyle(mapTheme);
  }
}

  void _onThemeChanged(String? value) async {
    if (value != null) {
      setState(() {
        selectedTheme = value;
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

      mapTheme = await await DefaultAssetBundle.of(context).loadString(themeFilePath);
      print('Loaded theme: $value');

      _updateMapTheme();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);
    //_updateMapTheme();
  }

  Future<void> _deleteSOSMarkerFromDatabase(String markerId) async {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('sos').child(markerId);

    try {
      await databaseReference.remove();
      print('SOS marker deleted successfully');
    } catch (error) {
      print('Failed to delete SOS marker: $error');
    }
  }

  void _deleteSOSMarker(String markerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this SOS marker?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSOSMarkerFromDatabase(markerId);
                setState(() {
                  _markers.removeWhere((marker) => marker.markerId.value == markerId);
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Map'),
        backgroundColor:  Color(0xFFFC766A),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedTheme,
                onChanged: _onThemeChanged,
                dropdownColor:  Color(0xFFFC766A),
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
          onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _updateMapTheme();
          //_retrieveSOSCoordinates();
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
