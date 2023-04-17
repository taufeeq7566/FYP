import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Checkpoint {
  final String name;
  final double latitude;
  final double longitude;
  bool isVisited;

  Checkpoint({required this.name, required this.latitude, required this.longitude, this.isVisited = false});
}

Checkpoint startLine = Checkpoint(
  name: 'Rumah 2264',
  latitude: 2.273677,
  longitude: 102.446864,
);

Checkpoint finishLine = Checkpoint(
  name: 'Rumah Fudhail',
  latitude: 2.273176,
  longitude: 102.446027,
);

