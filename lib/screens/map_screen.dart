import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');
  final LatLng _center = const LatLng(2.273664, 102.446846); // Center coordinate
  final double _radius = 15.0; // Radius of the geofence in meters
  Marker? _currentLocationMarker; // Marker for current location
  List<Checkpoint> checkpoints = []; // List to store retrieved checkpoints
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();



  @override
  void initState() {
    super.initState();
    _retrieveCheckpoints();
    _startLocationUpdates();
    _initializeNotifications();
    _listenForGeofenceEvents();
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
          checkpoints.add(Checkpoint(name: name, latitude: latitude, longitude: longitude));
          _markers.add(
            Marker(
              markerId: MarkerId(key),
              position: LatLng(latitude, longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Marker color is blue
              infoWindow: InfoWindow(title: name), // Set the checkpoint name as the title
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

      print('Checkpoints: $checkpoints'); // Print the list of checkpoints
    }
  });
}


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.moveCamera(CameraUpdate.newLatLngZoom(_center, 18.0)); // Set initial camera position
  }

  void _startLocationUpdates() {
    Timer.periodic(const Duration(seconds: 2), (_) {
      _getCurrentLocation();
    });
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      // Remove the previous marker if it exists
      if (_currentLocationMarker != null) {
        _markers.remove(_currentLocationMarker);
      }

      // Add the new marker for the current location
      _currentLocationMarker = Marker(
        markerId: const MarkerId('current'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Set marker color to red
        infoWindow: const InfoWindow(title: 'Your Current Location'),
      );

      _markers.add(_currentLocationMarker!);
    });
  }
void _initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // the notification image
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



  void _listenForGeofenceEvents() {
    Geolocator.getPositionStream().listen((Position position) {
      for (var checkpoint in checkpoints) {
        final double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          checkpoint.latitude,
          checkpoint.longitude,
        );

        if (distance <= 15 && !checkpoint.isVisited) {
          checkpoint.isVisited = true;
          _showNotification('You are in ${checkpoint.name}');
        } else if (distance > 15 && checkpoint.isVisited) {
          checkpoint.isVisited = false;
          _showNotification('You have passed ${checkpoint.name}');
        }
      }
    });
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
}

class Checkpoint {
  final String name;
  final double latitude;
  final double longitude;
  bool isVisited;

  Checkpoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isVisited = false,
  });

    @override
  String toString() {
    return 'Checkpoint(name: $name, latitude: $latitude, longitude: $longitude)';
  }
  
}
