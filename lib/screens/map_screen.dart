import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  late Position _currentPosition;
  final Set<Marker> _markers = {};
  final Geoflutterfire geo = Geoflutterfire();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setGeofence();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  Future<void> _setGeofence() async {
    final checkpoints = await FirebaseFirestore.instance.collection('checkpoints').get();
    checkpoints.docs.forEach((checkpoint) {
      final id = checkpoint.id;
      final data = checkpoint.data();
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      final checkpointRef = FirebaseFirestore.instance.collection('checkpoints').doc(id);
      final geoPoint = geo.point(latitude: latitude, longitude: longitude);
      checkpointRef.set({
        'geofence': geoPoint.data,
        'isVisited': false,
      }, SetOptions(merge: true));

      final radius = 50.0; // in meters
      final collectionReference = FirebaseFirestore.instance.collection('geofence');
      final geoFirePoint = geo.point(latitude: latitude, longitude: longitude);
      final geoFirePointData = {
        'checkpointId': id,
        'isVisited': false,
      };
      geo.collection(collectionRef: collectionReference).add({
        'position': geoFirePoint.data,
        'radius': radius,
        'data': geoFirePointData,
      });
    });
    _listenForGeofenceEvents();
  }

void _listenForGeofenceEvents() {
  final collectionReference = FirebaseFirestore.instance.collection('geofence');
  final stream = geo.collection(collectionRef: collectionReference).within(
    center: geo.point(latitude: _currentPosition.latitude, longitude: _currentPosition.longitude),
    radius: 50.0, field: '', // in meters
  );
  stream.listen((List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      final data = document.data() as Map<String, dynamic>; // Cast data to Map<String, dynamic>
      final checkpointId = data['data']?['checkpointId']; // Add null checks here
      final isVisited = data['data']?['isVisited']; // Add null checks here
      if (checkpointId != null && isVisited != null && !isVisited) {
        final checkpointRef = FirebaseFirestore.instance.collection('checkpoints').doc(checkpointId);
        checkpointRef.update({'isVisited': true});
      }
    });
  });
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Map Screen'),
    ),
    body: GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: _markers,
    ),
  );
}
}