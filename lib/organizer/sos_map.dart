import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SOSMap extends StatefulWidget {
  @override
  _SOSMapState createState() => _SOSMapState();
}

class _SOSMapState extends State<SOSMap> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};

  final LatLng _center = const LatLng(2.273664, 102.446846);

  @override
  void initState() {
    super.initState();
    _retrieveSOSCoordinates();
  }

  void _retrieveSOSCoordinates() {
    // Reference to the Firebase Realtime Database
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('sos');

  databaseReference.onValue.listen((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?; // Add the cast here
    _updateSOSMarkers(data);
  });
}

void _updateSOSMarkers(Map<dynamic, dynamic>? data) {
  if (data == null) return;

  setState(() {
    _markers.clear();

    data.forEach((key, value) {
      final latitude = value['latitude'];
      final longitude = value['longitude'];

      _markers.add(
        Marker(
          markerId: MarkerId(key),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'SOS Location',
            snippet: 'Latitude: $latitude, Longitude: $longitude', // Add the snippet with coordinates
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    });
  });
}


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
      ),
    );
  }
}
