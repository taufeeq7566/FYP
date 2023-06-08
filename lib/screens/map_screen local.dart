
import 'dart:async';

import 'package:checkpoint_geofence/models/checkpoint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

