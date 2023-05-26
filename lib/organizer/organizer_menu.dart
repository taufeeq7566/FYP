import 'package:checkpoint_geofence/organizer/checkpoint_map.dart';
import 'package:checkpoint_geofence/organizer/contestant_list.dart';
import 'package:checkpoint_geofence/organizer/sos_map.dart';
import 'package:checkpoint_geofence/screens/finisher_screen.dart';
import 'package:flutter/material.dart';

class OrganizerMenu extends StatefulWidget {
  @override
  _OrganizerMenuState createState() => _OrganizerMenuState();
}

class _OrganizerMenuState extends State<OrganizerMenu> {
  List<MenuButton> _menuButtons = [
    MenuButton(
      label: 'Emergency Tracker',
      icon: Icons.warning,
      screen: SOSMap(),
    ),
    MenuButton(
      label: 'Contestant List',
      icon: Icons.people,
      screen: ContestantList(),
    ),
    MenuButton(
      label: 'Finisher Tab',
      icon: Icons.check_circle_outline,
      screen: FinisherScreen(),
    ),
    MenuButton(
      label: 'Checkpoint Map',
      icon: Icons.map,
      screen: CheckpointMapScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout functionality
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 1.0,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: _menuButtons.map((button) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => button.screen),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  button.icon,
                  size: 64.0,
                ),
                SizedBox(height: 8.0),
                Text(
                  button.label,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MenuButton {
  final String label;
  final IconData icon;
  final Widget screen;

  MenuButton({
    required this.label,
    required this.icon,
    required this.screen,
  });
}
