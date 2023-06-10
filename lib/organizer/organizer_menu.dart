import 'package:checkpoint_geofence/main.dart';
import 'package:checkpoint_geofence/organizer/checkpoint_map.dart';
import 'package:checkpoint_geofence/organizer/contestant_list.dart';
import 'package:checkpoint_geofence/organizer/sos_map.dart';
import 'package:checkpoint_geofence/screens/finisher_screen.dart';
import 'package:flutter/material.dart';

class OrganizerMenu extends StatefulWidget {
  final List<Checkpoint> checkpoints;

  OrganizerMenu({required this.checkpoints});

  @override
  _OrganizerMenuState createState() => _OrganizerMenuState();
}

class _OrganizerMenuState extends State<OrganizerMenu> {
  final List<MenuButton> _menuButtons = [];
  bool _isRaceStarted = false;

  @override
  void initState() {
    super.initState();

_menuButtons.addAll([
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
]);

  }

  void _startRace() {
    setState(() {
      _isRaceStarted = true;
    });

    // Start the race timer or perform any other actions needed for starting the race
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16.0),
            childAspectRatio: 1.0,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: _menuButtons.map((button) {
              return InkWell(
                onTap: () {
                  if (button.onPressed != null) {
                    button.onPressed!(); // Invoke the onPressed callback
                  } else if (button.screen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => button.screen!),
                    );
                  }
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
          if (_isRaceStarted)
            Positioned(
              bottom: 16.0,
              left: MediaQuery.of(context).size.width / 2 - 75,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isRaceStarted = false;
                  });
                },
                child: Text('Stop Race'),
              ),
            ),
        ],
      ),
    );
  }
}

class MenuButton {
  final String label;
  final IconData icon;
  final Widget? screen;
  final VoidCallback? onPressed;

  MenuButton({
    required this.label,
    required this.icon,
    this.screen,
    this.onPressed,
  });
}
