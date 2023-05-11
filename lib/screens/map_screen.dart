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
  final Completer<GoogleMapController> _controller = Completer();
  late Position _currentPosition;
  final Set<Marker> _markers = {};
  final Geoflutterfire geo = Geoflutterfire();
  StreamSubscription<List<DocumentSnapshot<Map<String, dynamic>>>>? _subscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setGeofence();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  Future<void> _setGeofence() async {
    final checkpointsSnapshot = await FirebaseFirestore.instance
    .collection('checkpoints')
    .get();

for (final checkpointDoc in checkpointsSnapshot.docs) {
  final id = checkpointDoc.id;
  final data = checkpointDoc.data();
  final latitude = data['latitude'];
  final longitude = data['longitude'];
  final checkpointRef =
      FirebaseFirestore.instance.collection('checkpoints').doc(id);
  final geoPoint = geo.point(latitude: latitude, longitude: longitude);
  await checkpointRef.set(
    {
      'geofence': geoPoint.data,
      'isVisited': false,
    },
    SetOptions(merge: true),
  );
      const radius = 50.0; // in meters
      final collectionReference =
          FirebaseFirestore.instance.collection('geofence');
      final geoFirePoint = geo.point(latitude: latitude, longitude: longitude);
      final geoFirePointData = {
        'checkpointId': id,
        'isVisited': false,
      };
      geo.collection(collectionRef: collectionReference).add(
        {
          'position': geoFirePoint.data,
          'radius': radius,
          'data': geoFirePointData,
        },
      );
    }
    _listenForGeofenceEvents();
  }

void _listenForGeofenceEvents() {
  final collectionReference = FirebaseFirestore.instance.collection('geofence');
  final center = geo.point(
    latitude: _currentPosition.latitude,
    longitude: _currentPosition.longitude,
  );
  const radius = 50.0; // in meters

  _subscription = geo
      .collection(collectionRef: collectionReference)
      .within(center: center, radius: radius, field: 'position')
      .listen((List<DocumentSnapshot<Map<String, dynamic>>> documentList) {
    documentList.forEach((DocumentSnapshot<Map<String, dynamic>> document) {
      final data = document.data();
      final checkpointId = data?['data']?['checkpointId'];
      final isVisited = data?['data']?['isVisited'];
      if (checkpointId != null && isVisited != null && !isVisited!) {
        final checkpointRef =
            FirebaseFirestore.instance.collection('checkpoints').doc(checkpointId);
        checkpointRef.update({'isVisited': true}).then((_) {
          print('Checkpoint $checkpointId marked as visited.');
          // Perform desired actions when a checkpoint is visited
        }).catchError((error) {
          print('Failed to mark checkpoint as visited: $error');
        });
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
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: 16.0,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
