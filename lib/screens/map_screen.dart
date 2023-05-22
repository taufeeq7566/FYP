/*import 'package:flutter/material.dart';
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
  late GoogleMapController mapController;
  late Position currentPosition;
  final Set<Marker> _markers = {};
  final GeoFlutterFire geo = GeoFlutterFire();
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream;

  final LatLng _center = const LatLng(2.273664, 102.446846);
  final double _geofenceRadius = 50.0; // in meters

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
          target: _center,
          zoom: 18,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentPosition = position;
      _markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Your current Location'),
        ),
      );
    });
  }

  void _setGeofence() async {
    final checkpointsSnapshot =
        await FirebaseFirestore.instance.collection('Checkpoints').get();
    checkpointsSnapshot.docs.forEach((checkpointDoc) async {
      final id = checkpointDoc.id;
      final data = checkpointDoc.data();
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      final checkpointRef =
          FirebaseFirestore.instance.collection('Checkpoints').doc(id);
      final point = GeoFirePoint(latitude, longitude);
      await checkpointRef.set(
        {
          'position': point.data,
          'isVisited': false,
        },
        SetOptions(merge: true),
      );

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(title: 'Checkpoint'),
          ),
        );
      });
    });
  }

  void _listenForGeofenceEvents() {
    final collectionReference =
        FirebaseFirestore.instance.collection('Checkpoints');
    final center = geo.point(
      latitude: _center.latitude,
      longitude: _center.longitude,
    );

    final query = geo.collection(collectionRef: collectionReference).within(
      center: center,
      radius: _geofenceRadius,
      field: 'position',
    );

    _stream = query.switchMap((events) {
      final updatedMarkers = events.map((event) {
        final data = event.data() as Map<String, dynamic>;
        final markerId = MarkerId(event.id);
        final position = LatLng(data['position'].latitude, data['position'].longitude);
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

      setState(() {
        _markers.addAll(updatedMarkers.map((snapshot) {
          final position = snapshot.data!['position'] as GeoPoint;
          return Marker(
            markerId: MarkerId(snapshot.id),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Checkpoint'),
          );
        }));
      });

      return BehaviorSubject.seeded(updatedMarkers.cast<DocumentSnapshot<Map<String, dynamic>>>());
    });
  }
}*/ //code to implement firebase


//
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:checkpoint_geofence/models/checkpoint.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late Position currentPosition;
  final Set<Marker> _markers = {};
  final GeoFlutterFire geo = GeoFlutterFire();
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream;

  final LatLng _center = const LatLng(2.273664, 102.446846);
  final Set<Circle> _circles = {};
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Marker? _currentLocationMarker;
  Timer? _locationTimer;



  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setGeofence();
    _listenForGeofenceEvents();
    _initializeNotifications();
    _startLocationUpdates();
  }


  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('Marathon App'); // App icon name
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

void _showNotification(String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'geofence_channel',
    'Geofence Event',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Geofence Notification',
    message,
    platformChannelSpecifics,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        circles: _circles,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _getCurrentLocation();
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentPosition = position;

      // Remove the previous marker if it exists
      if (_currentLocationMarker != null) {
        _markers.remove(_currentLocationMarker);
      }

      // Add the new marker for the current location
      _currentLocationMarker = Marker(
        markerId: const MarkerId('current'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Your current Location'),
      );

      _markers.add(_currentLocationMarker!);
    });
  }

  void _setGeofence() {
    for (var checkpoint in checkpoints) {
      final id = checkpoint.name;
      final latitude = checkpoint.latitude;
      final longitude = checkpoint.longitude;
      final point = GeoFirePoint(latitude, longitude);

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: id),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );

        _markers.add(
          Marker(
            markerId: MarkerId('$id-geofence'),
            position: LatLng(latitude, longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
            zIndex: 0,
            visible: true,
          ),
        );

        _circles.add(
          Circle(
            circleId: CircleId('$id-geofence-circle'),
            center: LatLng(latitude, longitude),
            radius: 20, // Geofence radius in meters
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue.withOpacity(0.4),
            strokeWidth: 2,
          ),
        );
      });
    }
  }

  void _listenForGeofenceEvents() {
    Geolocator.getPositionStream().listen((Position position) {
      for (var checkpoint in checkpoints) {
        final double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          checkpoint.latitude,
          checkpoint.longitude,
        );

        if (distance <= 20 && !checkpoint.isVisited) {
          checkpoint.isVisited = true;
          _showNotification('You are in ${checkpoint.name}');
        } else if (distance > 20 && checkpoint.isVisited) {
          checkpoint.isVisited = false;
          _showNotification('You have passed ${checkpoint.name}');
        }
      }
    });
  }
}

