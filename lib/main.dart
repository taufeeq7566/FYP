import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:checkpoint_geofence/screens/map_screen.dart';
import 'package:checkpoint_geofence/models/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marathon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permission Handler"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              requestLocationAndCameraPermissions().then((granted) {
                if (granted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                }
              });
            },
            child: Text(
              "Request Permissions",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
