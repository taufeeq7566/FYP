import 'package:checkpoint_geofence/models/checkpoint.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CheckpointProvider with ChangeNotifier {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');
  List<Checkpoint> _checkpoints = [];

  List<Checkpoint> get checkpoints => _checkpoints;

  CheckpointProvider() {
    _retrieveCheckpoints();
  }

void _retrieveCheckpoints() {
  _databaseReference.once().then((DatabaseEvent event) {
    final snapshot = event.snapshot;
    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      List<Checkpoint> checkpoints = [];

      data.forEach((key, value) {
        checkpoints.add(Checkpoint.fromSnapshot(value));
      });

      _checkpoints = checkpoints;

      print('Checkpoints:');
      checkpoints.forEach((checkpoint) {
        print('Name: ${checkpoint.name}');
        print('Latitude: ${checkpoint.latitude}');
        print('Longitude: ${checkpoint.longitude}');
        print('Is Visited: ${checkpoint.isVisited}');
        print('------------------------');
      });

      notifyListeners();
    }
  }).catchError((error) {
    print('Failed to retrieve checkpoints: $error');
  });
}


}
