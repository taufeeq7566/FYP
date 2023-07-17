import 'package:checkpoint_geofence/models/contestant_provider.dart';
import 'package:checkpoint_geofence/spectator/spectator_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Application'),
        content: Text('Are you sure you want to exit the application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckpointProvider()),
        ChangeNotifierProvider(create: (_) => ContestantProvider()), // Add the ContestantProvider
      ],
      child: Consumer<CheckpointProvider>(
        builder: (context, checkpointProvider, _) {
          return MaterialApp(
            title: 'Marathon App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: WillPopScope(
              onWillPop: () async {
                final shouldExit = await _showExitConfirmationDialog(context);
                return shouldExit ?? false;
              },
              child: MyHomePage(),
            ),
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
  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Application'),
        content: Text('Are you sure you want to exit the application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Checkpoint> checkpoints =
        Provider.of<CheckpointProvider>(context).checkpoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Marathon App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFC766A),
        leading: IconButton(
          icon: Image.asset(
            'lib/assets/picture_assets/off.png',
            width: 40,
            height: 40,
          ),
          onPressed: () async {
            final shouldExit = await _showExitConfirmationDialog(context);
            if (shouldExit ?? false) {
              SystemNavigator.pop();
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/picture_assets/running_silhouette.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
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
                          builder: (context) =>
                              LoginScreen(checkpoints: checkpoints),
                        ),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFC766A),
                  elevation: 3,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  "Login as User",
                  style: TextStyle(color: Colors.white),
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
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFC766A),
                  elevation: 3,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  "Login as Spectator",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
