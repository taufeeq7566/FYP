import 'package:checkpoint_geofence/models/contestant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContestantList extends StatefulWidget {
  const ContestantList({Key? key}) : super(key: key);

  @override
  _ContestantListState createState() => _ContestantListState();
}

class _ContestantListState extends State<ContestantList> {
  TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final contestantProvider = Provider.of<ContestantProvider>(context);

  return Scaffold(
    appBar: AppBar(
      title: Text('Contestant List'),
      backgroundColor: Color(0xFFFC766A),
      actions: [
        IconButton(
          icon: Image.asset(
            'lib/assets/picture_assets/search.png',
            width: 70,
            height: 70,
          ),
          onPressed: () {
            setState(() {
              _isSearchVisible = !_isSearchVisible;
            });
          },
        ),
      ],
    ),
    body: Column(
      children: [
        Visibility(
          visible: _isSearchVisible,
          child: Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 5
      )
    ]
  ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                contestantProvider.searchQuery = value;
              },
              decoration: InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      labelText: 'Search',
      labelStyle: TextStyle(fontSize: 18),
      hintStyle: TextStyle(color: Colors.grey),
      prefixIcon: Icon(Icons.search, color: Colors.grey)
    ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Color(0xFF3F51B5),
            child: ListView.builder(
              itemCount: contestantProvider.filteredContestants.length,
              itemBuilder: (context, index) {
                Contestant contestant = contestantProvider.filteredContestants[index];
                return InkWell(
                  onTap: () {
                    bool isChecked = contestantProvider.checkedList[index];
                    contestantProvider.setCheckedState(index, !isChecked);
                  },
                  child: Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        contestant.fullname,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        contestant.email,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      leading: Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: contestantProvider.checkedList[index] ? Colors.green : Colors.transparent,
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 16.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

}
