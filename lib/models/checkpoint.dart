import 'package:firebase_database/firebase_database.dart';

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

  factory Checkpoint.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Checkpoint(
      name: data['name'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }

  static Future<List<Checkpoint>> fetchCheckpointsFromDatabase() async {
    final DatabaseReference checkpointsRef =
        FirebaseDatabase.instance.reference().child('checkpoints');

    try {
      DatabaseEvent event = await checkpointsRef.once();
      List<Checkpoint> checkpoints = [];

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          checkpoints.add(Checkpoint.fromSnapshot(value));
        });
      }

      return checkpoints;
    } catch (e) {
      print('Failed to fetch checkpoints: $e');
      return [];
    }
  }

  Future<void> saveToDatabase() async {
    try {
      final DatabaseReference checkpointRef =
          FirebaseDatabase.instance.reference().child('checkpoints');
      await checkpointRef.push().set(toMap());
      print('Checkpoint saved to Realtime Database');
    } catch (e) {
      print('Failed to save checkpoint: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

void _retrieveCheckpoints() async {
  List<Checkpoint> checkpoints = await Checkpoint.fetchCheckpointsFromDatabase();
  print('Checkpoints:');
  checkpoints.forEach((checkpoint) {
    print('Name: ${checkpoint.name}');
    print('Latitude: ${checkpoint.latitude}');
    print('Longitude: ${checkpoint.longitude}');
    print('Is Visited: ${checkpoint.isVisited}');
    print('------------------------');
  });
}
