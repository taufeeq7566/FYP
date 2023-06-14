import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FinisherScreen extends StatefulWidget {
  @override
  _FinisherScreenState createState() => _FinisherScreenState();
}

class _FinisherScreenState extends State<FinisherScreen> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  List<String> _finishers = [];

  @override
  void initState() {
    super.initState();
    _fetchFinishers();
  }

  Future<void> _fetchFinishers() async {
    DatabaseReference checkpointsRef = _databaseReference.child('checkpoints');
    DataSnapshot checkpointSnapshot =
        (await checkpointsRef.once()).snapshot;

    if (checkpointSnapshot.value == null) {
      return;
    }

    Map<dynamic, dynamic> checkpoints =
        checkpointSnapshot.value as Map<dynamic, dynamic>;
    int numCheckpoints = checkpoints.length;

    DatabaseReference leaderboardRef = _databaseReference.child('leaderboard');
    DataSnapshot leaderboardSnapshot =
        (await leaderboardRef.once()).snapshot;

    if (leaderboardSnapshot.value == null) {
      return;
    }

    Map<dynamic, dynamic> leaderboardData =
        leaderboardSnapshot.value as Map<dynamic, dynamic>;

    leaderboardData.forEach((key, value) {
      String fullName = key;
      Map<dynamic, dynamic> userCheckpoints = value['checkpoints'];

      if (userCheckpoints.length == numCheckpoints) {
        _finishers.add(fullName);
      }
    });

    setState(() {
      // Update the state to trigger a rebuild with the fetched finishers
      _finishers = _finishers;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Finishers'),
    ),
    body: ListView.builder(
      itemCount: _finishers.length,
      itemBuilder: (context, index) {
        String fullName = _finishers[index];
        return ListTile(
          title: Text(
            fullName,
            style: TextStyle(
              fontSize: 20, // Adjust the font size as desired
              fontWeight: FontWeight.bold, // Make the font bold
            ),
          ),
          leading: Icon(Icons.emoji_events), // Add the trophy icon
        );
      },
    ),
  );
}

}
