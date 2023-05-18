import 'package:flutter/material.dart';
import 'package:checkpoint_geofence/screens/map_screen.dart';
import 'package:checkpoint_geofence/screens/distance_screen.dart';
import 'package:checkpoint_geofence/screens/leaderboard_screen.dart';
import 'package:checkpoint_geofence/screens/finisher_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MenuButton> _menuButtons = [
    MenuButton(
      label: 'Map',
      icon: Icons.map,
      screen: MapScreen(),
    ),
    MenuButton(
      label: 'Distance',
      icon: Icons.directions_run,
      screen: DistanceScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Menu'),
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
