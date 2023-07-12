import 'package:checkpoint_geofence/models/contestant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContestantList extends StatelessWidget {
  const ContestantList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contestantProvider = Provider.of<ContestantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Contestant List'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          itemCount: contestantProvider.contestants.length,
          itemBuilder: (context, index) {
            Contestant contestant = contestantProvider.contestants[index];
            return InkWell(
              onTap: () {
                bool isChecked = contestantProvider.checkedList[index];
                contestantProvider.setCheckedState(index, !isChecked);
              },
              child: Card(
                color: Colors.purple,
                child: ListTile(
                  title: Text(
                    contestant.fullname,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    contestant.email,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: contestantProvider.checkedList[index] ? Colors.green : Colors.transparent,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
