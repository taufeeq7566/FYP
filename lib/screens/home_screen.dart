import 'package:checkpoint_geofence/main.dart';
import 'package:checkpoint_geofence/models/sos_button.dart';
import 'package:checkpoint_geofence/screens/distance_screen.dart';
import 'package:checkpoint_geofence/screens/finisher_screen.dart';
import 'package:checkpoint_geofence/screens/leaderboard_screen.dart';
import 'package:checkpoint_geofence/screens/map_screen.dart';
import 'package:flutter/material.dart';

import '../models/checkpoint.dart';

class HomeScreen extends StatefulWidget {
  final List<Checkpoint> checkpoints;

  HomeScreen({required this.checkpoints});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<MenuButton> _menuButtons;

  @override
  void initState() {
    super.initState();
    _menuButtons = [
      MenuButton(
        label: 'Map',
        icon: Icons.map,
        screen: MapScreen(checkpoints: widget.checkpoints),
      ),
      MenuButton(
        label: 'Distance',
        icon: Icons.directions_run,
        onPressed: () => _startRace(),
        screen: null,
      ),
      MenuButton(
        label: 'Leaderboard',
        icon: Icons.emoji_events,
        screen: LeaderboardScreen(),
      ),
      MenuButton(
        label: 'Finisher',
        icon: Icons.check_circle,
        screen: FinisherScreen(),
      ),
    ];
  }

  void _startRace() {
    // Code to start the race
    String userEmail = ''; // Retrieve the userEmail from wherever it is available
    List<DistanceCheckpoint> distanceCheckpoints = widget.checkpoints.map((checkpoint) {
      return DistanceCheckpoint(
        name: checkpoint.name,
        latitude: checkpoint.latitude,
        longitude: checkpoint.longitude,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DistanceScreen(
          checkpoints: distanceCheckpoints,
          userEmail: userEmail,
          onRaceFinished: (userEmail) {
            // Handle race finished with userEmail
            // e.g., Update the state or perform any required actions
            // based on the userEmail
            print('Race finished for user: $userEmail');
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Menu'),
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
          Positioned(
            bottom: 32.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Press for medic',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                Center(
                  child: SizedBox(
                    width: 80.0,
                    height: 80.0,
                    child: ElevatedButton(
                      onPressed: () {
                        SOSButton.sendSOS(); // Call the sendSOS() function from sos_button.dart
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MedicDialog();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: Colors.red,
                      ),
                      child: Icon(
                        Icons.warning,
                        size: 40.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
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


class MedicDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Medic Assistance'),
      content: Text('Medic will come shortly'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.close),
        ),
      ],
    );
  }
}
