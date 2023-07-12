import 'package:checkpoint_geofence/main.dart';
import 'package:checkpoint_geofence/screens/finisher_screen.dart';
import 'package:checkpoint_geofence/screens/leaderboard_screen.dart';
import 'package:checkpoint_geofence/spectator/spectator_map.dart';
import 'package:flutter/material.dart';

class SpectatorMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spectator Menu'),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MenuButton(
                  label: 'Checkpoints Map',
                  iconAsset: 'lib/assets/picture_assets/checkpoint map.png',
                  screen: SpectatorMapScreen(),
                ),
                SizedBox(height: 20.0),
                MenuButton(
                  label: 'Leaderboard Page',
                  iconAsset: 'lib/assets/picture_assets/leaderboard icon.png',
                  screen: LeaderboardScreen(),
                ),
                SizedBox(height: 20.0),
                MenuButton(
                  label: 'Finishers Page',
                  iconAsset: 'lib/assets/picture_assets/Finisher.png',
                  screen: FinisherScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MenuButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final Widget? screen;

  const MenuButton({
    required this.label,
    required this.iconAsset,
    this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen!),
          );
        }
      },
      child: Container(

        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconAsset,
              width: 100.0,
              height: 100.0,
            ),
            SizedBox(width: 12.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
            ),
            ),
          ],
        ),
      ),
    );
  }
}





