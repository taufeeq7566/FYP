import 'package:checkpoint_geofence/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/checkpoint.dart';
import 'models/checkpoint_provider.dart';
import 'models/permission_handler.dart';
import 'route.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
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
                    builder: (context) => HomeScreen(checkpoints: checkpoints),
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
