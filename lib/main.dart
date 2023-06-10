import 'package:checkpoint_geofence/models/permission_handler.dart';
import 'package:checkpoint_geofence/screens/home_screen.dart';
import 'package:checkpoint_geofence/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'route.dart';

class Checkpoint {
  final String name;
  final double latitude;
  final double longitude;
  bool isVisited;
  Duration? stopwatchTime;


  Checkpoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isVisited = false,
    this.stopwatchTime,
  });

  factory Checkpoint.fromMap(Map<dynamic, dynamic> map) {
    return Checkpoint(
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('checkpoints');
  List<Checkpoint> checkpoints = [];

  @override
  void initState() {
    super.initState();
    _retrieveCheckpoints();
  }

  void _retrieveCheckpoints() {
    _databaseReference.once().then((DatabaseEvent event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<Checkpoint> checkpoints = [];

        data.forEach((key, value) {
          checkpoints.add(Checkpoint.fromMap(value));
        });

        setState(() {
          this.checkpoints = checkpoints;
        });

        print('Checkpoints:');
        checkpoints.forEach((checkpoint) {
          print('Name: ${checkpoint.name}');
          print('Latitude: ${checkpoint.latitude}');
          print('Longitude: ${checkpoint.longitude}');
          print('Is Visited: ${checkpoint.isVisited}');
          print('------------------------');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marathon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(checkpoints: checkpoints),
      routes: {
        AppRoute.home: (context) => LoginScreen(checkpoints: checkpoints),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<Checkpoint> checkpoints;

  const MyHomePage({Key? key, required this.checkpoints}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
