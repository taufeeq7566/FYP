import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ContestantProvider with ChangeNotifier {
  List<Contestant> contestants = [];
  List<bool> checkedList = [];

  ContestantProvider() {
    fetchContestants();
  }

  Future<void> fetchContestants() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child('users');
    DatabaseEvent snapshot = await dbRef.once();
    DataSnapshot dataSnapshot = snapshot.snapshot;

    contestants.clear();
    checkedList.clear();

    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> contestantsData = dataSnapshot.value as Map<dynamic, dynamic>;

      contestantsData.forEach((key, value) {
        contestants.add(
          Contestant(
            fullname: value['fullname'],
            email: value['email'],
          ),
        );
        checkedList.add(false);
      });
    }

    notifyListeners();
  }

  void setCheckedState(int index, bool value) {
    checkedList[index] = value;
    notifyListeners();
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
