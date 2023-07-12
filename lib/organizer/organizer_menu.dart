import 'package:checkpoint_geofence/main.dart';
import 'package:checkpoint_geofence/organizer/checkpoint_map.dart';
import 'package:checkpoint_geofence/organizer/contestant_list.dart';
import 'package:checkpoint_geofence/organizer/sos_map.dart';
import 'package:checkpoint_geofence/screens/finisher_screen.dart';
import 'package:checkpoint_geofence/screens/leaderboard_screen.dart';
import 'package:flutter/material.dart';

import '../models/checkpoint.dart';

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
        iconAsset: 'lib/assets/picture_assets/emergency_icon.png',
        screen: SOSMap(),
      ),
      MenuButton(
        label: 'Contestant List',
        iconAsset: 'lib/assets/picture_assets/contestant_list.png',
        screen: ContestantList(),
      ),
      MenuButton(
        label: 'Finisher Tab',
        iconAsset: 'lib/assets/picture_assets/Finisher.png',
        screen: FinisherScreen(),
      ),
      MenuButton(
        label: 'Checkpoint Map',
        iconAsset: 'lib/assets/picture_assets/checkpoint map.png',
        screen: CheckpointMapScreen(),
      ),
      MenuButton(
        label: 'Leaderboard',
        iconAsset: 'lib/assets/picture_assets/leaderboard icon.png',
        screen: LeaderboardScreen(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Menu'),
        backgroundColor: Colors.purple,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                'lib/assets/picture_assets/logout.png',
                width: 30.0,
                height: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            width: 700, // Adjust the width as needed
            height: 700.0, // Adjust the height as needed
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              childAspectRatio: 1.3,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: [
                ..._menuButtons.map((button) {
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
                        color: Colors.purple,
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
              ],
            ),
          ),
        ),
      ),
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

