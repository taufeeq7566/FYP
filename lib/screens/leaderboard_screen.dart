import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('leaderboard');

  List<LeaderboardEntry> _leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

Future <void> _fetchLeaderboardData() async {
  _databaseReference.onValue.listen((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>;
    List<LeaderboardEntry> leaderboard = [];
    data.forEach((key, value) {
      String fullName = key;
      Map<dynamic, dynamic> checkpoints = value['checkpoints'];

      List<CheckpointEntry> checkpointEntries = [];
      String? finishLineTime;

checkpoints.forEach((checkpoint, checkpointTime) {
  if (checkpointTime == '00:00:00') {
    checkpointEntries.insert(
      0,
      CheckpointEntry(
        checkpoint: 'Starting Line',
        checkpointTime: checkpointTime,
      ),
    );
  } else if (checkpointTime == checkpoints.values.last) {
    finishLineTime = checkpointTime;
  } else {
    String checkpointName = 'Checkpoint ${checkpointEntries.length + 1}';
    checkpointEntries.add(
      CheckpointEntry(
        checkpoint: checkpointName,
        checkpointTime: checkpointTime,
      ),
    );
  }
});


      // Sort the checkpoint entries based on their names
      checkpointEntries.sort((a, b) => a.checkpoint.compareTo(b.checkpoint));

      if (finishLineTime != null) {
        checkpointEntries.add(
          CheckpointEntry(
            checkpoint: 'Finish Line',
            checkpointTime: finishLineTime!,
          ),
        );
      }

      leaderboard.add(
        LeaderboardEntry(
          fullName: fullName,
          checkpointEntries: checkpointEntries,
        ),
      );
    });

leaderboard.sort((a, b) {
  // If the first entry has the "Starting Line" checkpoint, it should be first
  if (a.checkpointEntries[0].checkpoint == 'Starting Line') {
    // If the second entry also has the "Starting Line" checkpoint, compare their last checkpoint times
    if (b.checkpointEntries[0].checkpoint == 'Starting Line') {
      return a.lastCheckpointTime.compareTo(b.lastCheckpointTime);
    }
    return -1; // First entry has the "Starting Line" checkpoint, so it should be first
  }
  // If the second entry has the "Starting Line" checkpoint, it should be first
  else if (b.checkpointEntries[0].checkpoint == 'Starting Line') {
    return 1;
  }
  // Sort based on the number of checkpoint entries
  return a.checkpointEntries.length.compareTo(b.checkpointEntries.length);
});



    setState(() {
      _leaderboardData = leaderboard;
    });
  });
}


@override
void dispose() {
  super.dispose();
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Leaderboard'),
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        await _fetchLeaderboardData();
      },
      child: ListView.builder(
        itemCount: _leaderboardData.length,
        itemBuilder: (context, index) {
          LeaderboardEntry entry = _leaderboardData[index];
          return ListTile(
            title: Text(entry.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entry.checkpointEntries.map((checkpointEntry) {
                return Text('${checkpointEntry.checkpoint}: ${checkpointEntry.checkpointTime}');
              }).toList(),
            ),
            trailing: Text('Rank: ${index + 1}'),
          );
        },
      ),
    ),
  );
}



}

class LeaderboardEntry {
  final String fullName;
  final List<CheckpointEntry> checkpointEntries;

  LeaderboardEntry({
    required this.fullName,
    List<CheckpointEntry>? checkpointEntries,
  }) : checkpointEntries = checkpointEntries ?? [];

  String get lastCheckpointTime {
    if (checkpointEntries.isNotEmpty) {
      return checkpointEntries.last.checkpointTime;
    }
    return '';
  }
}

class CheckpointEntry {
  final String checkpoint;
  final String checkpointTime;

  CheckpointEntry({required this.checkpoint, required this.checkpointTime});
}

