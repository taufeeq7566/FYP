import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class SOSButton {
  static Future<void> sendSOS() async {
    // Retrieve user's current location
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Store location data in Firebase Realtime Database
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('sos');

    await databaseReference.push().set({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }
}
