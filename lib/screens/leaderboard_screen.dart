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
  if (a.checkpointEntries.length != b.checkpointEntries.length) {
    // Sort based on the number of checkpoint entries
    return a.checkpointEntries.length.compareTo(b.checkpointEntries.length);
  } else {
    // If the number of checkpoint entries is the same, compare their last checkpoint times
    return a.lastCheckpointTime.compareTo(b.lastCheckpointTime);
  }
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
          int rank = index + 1;
          String medalImage = '';

          if (rank == 1) {
            medalImage = 'lib/assets/picture_assets/medalG.png';
          } else if (rank == 2) {
            medalImage = 'lib/assets/picture_assets/medalS.png';
          } else if (rank == 3) {
            medalImage = 'lib/assets/picture_assets/medalB.png';
          }

          Widget rankWidget;
          if (rank <= 3) {
            rankWidget = SizedBox(
              width: 55,
              height: 55,
              child: Image.asset(
                medalImage,
                fit: BoxFit.contain,
              ),
            );
          } else {
            rankWidget = SizedBox(
              width: 55,
              height: 55,
              child: Center(
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            );
          }

          return ListTile(
            leading: rankWidget,
            title: Text(entry.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entry.checkpointEntries.map((checkpointEntry) {
                return Text('${checkpointEntry.checkpoint}: ${checkpointEntry.checkpointTime}');
              }).toList(),
            ),
            trailing: Text('Rank: $rank'),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

