import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ContestantProvider with ChangeNotifier {
  List<Contestant> contestants = [];
  List<bool> checkedList = [];
  String _searchQuery = '';

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
        String role = value['role'];
        if (role == 'UserRole.contestant') {
          contestants.add(
            Contestant(
              fullname: value['fullname'],
              email: value['email'],
            ),
          );
          checkedList.add(false);
        }
      });
    }

    notifyListeners();
  }

  String get searchQuery => _searchQuery;

  set searchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<Contestant> get filteredContestants {
    if (_searchQuery.isEmpty) {
      return contestants;
    } else {
      return contestants.where((contestant) {
        final lowercaseName = contestant.fullname.toLowerCase();
        return lowercaseName.contains(_searchQuery);
      }).toList();
    }
  }

  void setCheckedState(int index, bool value) {
    checkedList[index] = value;
    notifyListeners();
  }

    List<Contestant> searchContestants(String query) {
    final lowercaseQuery = query.toLowerCase();
    return contestants.where((contestant) {
      final lowercaseName = contestant.fullname.toLowerCase();
      return lowercaseName.contains(lowercaseQuery);
    }).toList();
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
