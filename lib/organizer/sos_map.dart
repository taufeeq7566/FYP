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
  final Completer<GoogleMapController> _controller = Completer();
  String mapTheme = '';
  final Set<Marker> _markers = {};

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
  DefaultAssetBundle.of(context)
      .loadString('lib/assets/maptheme/standard_mode.json')
      .then((value) {
    mapTheme = value;
    _retrieveSOSCoordinates();
  });
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
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      _updateSOSMarkers(data);
      _loadMapTheme();
    });
  }

Future<BitmapDescriptor> _createCustomMarker() async {
  final Uint8List markerIcon =
      await getBytesFromAsset('lib/assets/picture_assets/emergency_marker.png', 100, 100);
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



  void _updateSOSMarkers(Map<dynamic, dynamic>? data) {
    if (data == null) return;

    setState(() {
      _markers.clear();

      data.forEach((key, value) async {
        final latitude = value['latitude'];
        final longitude = value['longitude'];

_markers.add(
  Marker(
    markerId: MarkerId(key),
    position: LatLng(latitude, longitude),
    infoWindow: InfoWindow(
      title: 'SOS Location',
      snippet: 'Latitude: $latitude, Longitude: $longitude',
    ),
    //icon: BitmapDescriptor.defaultMarker,
    icon: await _createCustomMarker(),
  ),
);
      });
    });
  }

  void _updateMapTheme() async {
    final GoogleMapController controller = await _controller.future;
    controller.setMapStyle(mapTheme);
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

    mapTheme = await DefaultAssetBundle.of(context).loadString(themeFilePath);
    print('Loaded theme: $value');
    
    _updateMapTheme();
  }
}

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('SOS Map'),
      backgroundColor: Colors.purple,
      actions: [
        Container(
          padding: EdgeInsets.only(right: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedTheme,
              onChanged: _onThemeChanged,
              dropdownColor: Colors.purple,
              items: themeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Image.asset(
                        'lib/assets/picture_assets/theme.png',
                        width: 20,
                        height: 20,
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
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
      ),
  );
}

}