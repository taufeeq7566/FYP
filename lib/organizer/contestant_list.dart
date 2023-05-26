import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ContestantList extends StatefulWidget {
  const ContestantList({Key? key}) : super(key: key);

  @override
  _ContestantListState createState() => _ContestantListState();
}

class _ContestantListState extends State<ContestantList> {
  List<Contestant> contestants = [];

  @override
  void initState() {
    super.initState();
    fetchContestants(UserRole.contestant);
  }

Future<void> fetchContestants(UserRole role) async {
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child('users');
  DatabaseEvent snapshot = await dbRef.once();
  DataSnapshot dataSnapshot = snapshot.snapshot;

  Map<dynamic, dynamic> contestantsData = dataSnapshot.value as Map<dynamic, dynamic>;

  contestantsData.forEach((key, value) {
    if (value['role'] == role.toString()) {
      contestants.add(
        Contestant(
          fullname: value['fullname'],
          email: value['email'],
          // Add other contestant details as needed
        ),
      );
    }
  });

  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contestant List'),
      ),
      body: ListView.builder(
        itemCount: contestants.length,
        itemBuilder: (context, index) {
          Contestant contestant = contestants[index];
          return ListTile(
            title: Text(contestant.fullname),
            subtitle: Text(contestant.email),
            // Display other contestant details as needed
          );
        },
      ),
    );
  }
}

class Contestant {
  final String fullname;
  final String email;

  Contestant({
    required this.fullname,
    required this.email,
  });
}

enum UserRole {
  contestant,
  organizer,
}
