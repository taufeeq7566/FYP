import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:rxdart/rxdart.dart';

// Define the MockDocumentSnapshot class
// Define a wrapper class for DocumentSnapshot
class MockDocumentSnapshot<T> {
  final String id;
  final T? data;
  final bool exists;
  final SnapshotMetadata metadata;

  MockDocumentSnapshot({
    required this.id,
    this.data,
    required this.exists,
    required this.metadata,
  });
}
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late Position _currentPosition;
  final Set<Marker> _markers = {};
  final GeoFlutterFire geo = GeoFlutterFire();
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setGeofence();
    _listenForGeofenceEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  void _setGeofence() async {
    final checkpointsSnapshot =
        await FirebaseFirestore.instance.collection('checkpoints').get();
    checkpointsSnapshot.docs.forEach((checkpointDoc) async {
      final id = checkpointDoc.id;
      final data = checkpointDoc.data();
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      final checkpointRef =
          FirebaseFirestore.instance.collection('checkpoints').doc(id);
      final point = GeoFirePoint(latitude, longitude);
      await checkpointRef.set(
        {
          'position': point.data,
          'isVisited': false,
        },
        SetOptions(merge: true),
      );
    });
  }

 void _listenForGeofenceEvents() {
    final collectionReference =
        FirebaseFirestore.instance.collection('checkpoints');
    final center = geo.point(
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
    );
    final radius = 50.0; // in meters

    final query = geo.collection(collectionRef: collectionReference).within(
      center: center,
      radius: radius,
      field: 'position',
    );

_stream = query.switchMap((events) {
  final updatedMarkers = events.map((event) {
    final data = event.data() as Map<String, dynamic>;  // Explicitly cast data to Map<String, dynamic>
    final markerId = MarkerId(event.id);
    final position = LatLng(data['position']?.latitude, data['position']?.longitude);
    final isVisited = data['isVisited'] ?? false;

    final documentData = {
      'position': GeoPoint(position.latitude, position.longitude),
      'isVisited': isVisited,
    };

    return MockDocumentSnapshot<Map<String, dynamic>>(
      id: event.id,
      data: documentData,
      exists: true,
      metadata: event.metadata,
    );
  }).toList();

  return BehaviorSubject.seeded(updatedMarkers.cast<DocumentSnapshot<Map<String, dynamic>>>());
});


  

}

}