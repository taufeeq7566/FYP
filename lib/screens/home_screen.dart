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
  final String email;

  HomeScreen({required this.checkpoints, required this.email, Key? key}) : super(key: key);

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
        iconAsset: 'lib/assets/picture_assets/checkpoint map.png',
        screen: MapScreen(checkpoints: widget.checkpoints),
      ),
      MenuButton(
        label: 'Distance',
        iconAsset: 'lib/assets/picture_assets/distanceButton.png',
        onPressed: () => _startRace(),
      ),
      MenuButton(
        label: 'Leaderboard',
        iconAsset: 'lib/assets/picture_assets/leaderboard icon.png',
        screen: LeaderboardScreen(),
      ),
      MenuButton(
        label: 'Finisher',
        iconAsset: 'lib/assets/picture_assets/Finisher.png',
        screen: FinisherScreen(),
      ),
    ];
  }

  void _startRace() {
    String userEmail = widget.email;
    List<DistanceCheckpoint> distanceCheckpoints = widget.checkpoints.map((checkpoint) {
      return DistanceCheckpoint(
        name: checkpoint.name,
        latitude: checkpoint.latitude,
        longitude: checkpoint.longitude,
        stopwatchTime: null,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DistanceScreen(
          checkpoints: distanceCheckpoints,
          userEmail: userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contestant Menu'),
        backgroundColor: Color(0xFFFC766A),
        actions: [
 GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  },
  child: Container(
    padding: EdgeInsets.all(12.0),
    child: Image.asset(
      'lib/assets/picture_assets/logout.png',
      width: 45.0,
      height: 45.0,
    ),
  ),
),

        ],
      ),
      body: Container(
        color:Color(0xFF3F51B5),
        child: Center(
          child: Container(
            width: 700, // Adjust the width as needed
            height: 500.0, // Adjust the height as needed
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              childAspectRatio: 1.3,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: _menuButtons.map((button) {
                return InkWell(
                  onTap: () {
                    if (button.onPressed != null) {
                      button.onPressed!();
                    } else if (button.screen != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => button.screen!),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:Color(0xFFFC766A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          button.iconAsset,
                          width: 64.0,
                          height: 64.0,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          button.label,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 700.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Press In Case Of Emergency',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Emergency Call'),
                      content: Text('Are you sure you want to call the medic?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            SOSButton.sendSOS(); // Call the sendSOS() function from sos_button.dart
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return MedicDialog();
                              },
                            );
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor: Colors.red,
              child: Icon(
                Icons.warning,
                size: 40.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class MenuButton {
  final String label;
  final String iconAsset;
  final Widget? screen;
  final VoidCallback? onPressed;

  MenuButton({
    required this.label,
    required this.iconAsset,
    this.screen,
    this.onPressed,
  });
}

class MedicDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Medic Assistance'),
      content: Text('Medic is on the way. Please wait.'),
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
