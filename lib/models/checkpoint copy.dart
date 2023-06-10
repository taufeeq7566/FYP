/*import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Future<void> saveToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('checkpoints')
          .add(toMap());
      print('Checkpoint saved to Firestore');
    } catch (e) {
      print('Failed to save checkpoint: $e');
    }
  }
}

List<Checkpoint> checkpoints = [
  Checkpoint(
    name: 'Checkpoint 1 (Taufeeq\'s house)',
    latitude: 2.273680,
    longitude: 102.446841,
  ),
  Checkpoint(
    name: 'Checkpoint 2 (Fudhail\'s house)',
    latitude: 2.273468,
    longitude: 102.445838,
  ),
  Checkpoint(
    name: 'Checkpoint 3 (Nuwairah\'s house)',
    latitude: 2.272310,
    longitude: 102.445977,
  ),
  Checkpoint(
    name: 'Checkpoint 4 (Asam Pedas Restaurant)',
    latitude: 2.271345,
    longitude: 102.445306,
  ),
];
*/