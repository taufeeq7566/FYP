import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../organizer/checkpoint_map.dart';

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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFC766A),
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
              onPressed: _isLoading ? null : _showConfirmationDialog,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFC766A),
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to save this checkpoint?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveCheckpoint();
                _showLoadingDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog() {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16.0),
                  Text('Saving checkpoint...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Simulate a delay to show the loading indicator
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CheckpointMapScreen()),
      );
    });
  }

  void _saveCheckpoint() {
    String name = nameController.text;
    double latitude = double.tryParse(latitudeController.text) ?? 0.0;
    double longitude = double.tryParse(longitudeController.text) ?? 0.0;

    _databaseReference.push().set({
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}

  final TextEditingController nameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFC766A),
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
    _showSaveConfirmationDialog(context, name, latitude, longitude);
  } else {
    // Show an error message or handle invalid input
  }
},
              child: Text('Save'),
            style: ElevatedButton.styleFrom(
            primary:Color(0xFFFC766A),
            textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }

void _showSaveConfirmationDialog(
  BuildContext context,
  String name,
  double latitude,
  double longitude,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to save the checkpoint?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the confirmation dialog

              // Show a loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16.0),
                        Text('Saving checkpoint...'),
                      ],
                    ),
                  );
                },
              );

              // Save the new checkpoint to the Realtime Database
              _saveCheckpoint(name, latitude, longitude).then((_) {
                // Close the loading dialog
                Navigator.of(context).pop();

                // Navigate back to checkpoint_map.dart
                Navigator.pop(context, {
                  'name': name,
                  'latitude': latitude,
                  'longitude': longitude,
                });
              });
            },
          ),
        ],
      );
    },
  );
}

Future<void> _saveCheckpoint(
  String name,
  double latitude,
  double longitude,
) async {
  await _databaseReference.push().set({
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
  });
}

