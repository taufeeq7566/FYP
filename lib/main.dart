import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:checkpoint_geofence/models/permission_handler.dart';
import 'route.dart';
import 'package:checkpoint_geofence/screens/home_screen.dart';

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
      routes: {
        AppRoute.home: (context) => HomeScreen(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marathon App"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              requestLocationAndCameraPermissions().then((granted) {
                if (granted) {
                  Navigator.pushReplacementNamed(context, AppRoute.home);
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
