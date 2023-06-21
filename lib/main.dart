import 'package:checkpoint_geofence/spectator/spectator_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';
import 'models/checkpoint.dart';
import 'models/checkpoint_provider.dart';
import 'models/permission_handler.dart';
import 'route.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Workmanager workmanager = Workmanager();
  await workmanager.initialize(callbackDispatcher);
  await workmanager.registerPeriodicTask(
    "geofence_task",
    "geofenceTask",
    initialDelay: Duration(seconds: 5),
    frequency: Duration(minutes: 15),
  );
  runApp(MyApp());

  final checkpointProvider = CheckpointProvider();

  Workmanager().initialize((taskName, inputData) => callbackDispatcher(checkpointProvider.checkpoints),
      isInDebugMode: true);
}



void callbackDispatcher(List<Checkpoint> checkpoints) {
  Workmanager workmanager = Workmanager();
  workmanager.executeTask((taskName, inputData) {
    if (taskName == "geofenceTask") {
      // Perform geofence checks for each checkpoint using Geolocator.getPositionStream()
      Geolocator.getPositionStream().listen((position) {
        for (var checkpoint in checkpoints) {
          final double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            checkpoint.latitude,
            checkpoint.longitude,
          );

          if (distance <= checkpoint.radius && !checkpoint.isVisited) {
            // TODO: Handle geofence event when user enters checkpoint
          } else if (distance > checkpoint.radius && checkpoint.isVisited) {
            // TODO: Handle geofence event when user exits checkpoint
          }
        }
      });
    }

    return Future.value(true);
  });
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckpointProvider(),
      child: Consumer<CheckpointProvider>(
        builder: (context, checkpointProvider, _) {
          return MaterialApp(
            title: 'Marathon App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: MyHomePage(),
            routes: {
              AppRoute.home: (context) => LoginScreen(checkpoints: checkpointProvider.checkpoints),
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Checkpoint> checkpoints = Provider.of<CheckpointProvider>(context).checkpoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Marathon App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                requestLocationAndCameraPermissions().then((granted) {
                  if (granted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(checkpoints: checkpoints),
                      ),
                    );
                  }
                });
              },
              child: const Text(
                "Login as User",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpectatorMenu(),
                  ),
                );
              },
              child: const Text(
                "Login as Spectator",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
