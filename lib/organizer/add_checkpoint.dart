import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddCheckpointScreen extends StatefulWidget {
  @override
  _AddCheckpointScreenState createState() => _AddCheckpointScreenState();
}

class _AddCheckpointScreenState extends State<AddCheckpointScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Checkpoint'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                double latitude = double.tryParse(latitudeController.text) ?? 0.0;
                double longitude = double.tryParse(longitudeController.text) ?? 0.0;

                if (name.isNotEmpty && latitude != 0.0 && longitude != 0.0) {
                  _saveCheckpoint(name, latitude, longitude);
                  Navigator.pop(context, {
                    'key': _databaseReference.push().key,
                    'latitude': latitude,
                    'longitude': longitude,
                  });
                } else {
                  // Show an error message or handle invalid input
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCheckpoint(String name, double latitude, double longitude) {
    _databaseReference.push().set({
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}
