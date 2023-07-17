import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/checkpoint.dart';

class MapScreen extends StatefulWidget {
  final List<Checkpoint> checkpoints;

  MapScreen({required this.checkpoints});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final LatLng _center = const LatLng(2.273664, 102.446846); // Center coordinate
  final double _radius = 15.0; // Radius of the geofence in meters
  Marker? _currentLocationMarker; // Marker for current location
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<Position>? _positionStreamSubscription;

  List<String> themeOptions = [
    'Standard',
    'Retro',
    'Dark',
    'Aubergine',
  ];
  String _selectedTheme = 'Standard';
  String _mapTheme = '';

  @override
  void initState() {
    super.initState();
        DefaultAssetBundle.of(context)
        .loadString('lib/assets/maptheme/standard_mode.json')
        .then((value) {
      _mapTheme = value;
    });
    _startLocationUpdates();
    _initializeNotifications();
    _listenForGeofenceEvents();
    _loadMapTheme();
  }

  void _startLocationUpdates() {
    _getCurrentLocation(); // Initial location update

    // Continuously update location
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      _getCurrentLocation();
    });
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (this.mounted) {
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
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      for (var checkpoint in widget.checkpoints) {
        final double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          checkpoint.latitude,
          checkpoint.longitude,
        );

        if (distance <= _radius && !checkpoint.isVisited) {
          if (mounted) {
            setState(() {
              checkpoint.isVisited = true;
            });
          }
          _showNotification('You are in ${checkpoint.name}');
        } else if (distance > _radius && checkpoint.isVisited) {
          if (mounted) {
            setState(() {
              checkpoint.isVisited = false;
            });
          }
          _showNotification('You have passed ${checkpoint.name}');
        }
      }
    });
  }

  void _loadMapTheme() async {
    _mapTheme = await DefaultAssetBundle.of(context).loadString('lib/assets/maptheme/standard_mode.json');
    _updateMapTheme();
  }

  void _updateMapTheme() async {
    final GoogleMapController controller = await _controller.future;
    controller.setMapStyle(_mapTheme);
  }

void _onThemeChanged(String? value) async {
  if (value != null) {
    setState(() {
      _selectedTheme = value;
    });

    switch (value) {
      case 'Retro':
        // Load retro theme
        _mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/retro_mode.json');
        break;
      case 'Standard':
        // Load normal theme
        _mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/standard_mode.json');
        break;
      case 'Dark':
        // Load dark theme
        _mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/dark_mode.json');
        break;
      case 'Aubergine':
        // Load aubergine theme
        _mapTheme = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maptheme/aubergine_mode.json');
        break;
    }

    _updateMapTheme();
  }
}

  @override
  Widget build(BuildContext context) {
    for (var checkpoint in widget.checkpoints) {
      _markers.add(
        Marker(
          markerId: MarkerId(checkpoint.name),
          position: LatLng(checkpoint.latitude, checkpoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: checkpoint.name),
        ),
      );

      _circles.add(
        Circle(
          circleId: CircleId(checkpoint.name),
          center: LatLng(checkpoint.latitude, checkpoint.longitude),
          radius: _radius,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.3),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contestant Map'),
        backgroundColor: Color(0xFFFC766A),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTheme,
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
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          _controller.complete(controller);
          _updateMapTheme();
        },
        markers: _markers,
        circles: _circles,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
      ),
    );
  }

  @override
  void dispose() {
    //mapController.dispose();
    //_positionStreamSubscription?.cancel();
    super.dispose();
  }
}
