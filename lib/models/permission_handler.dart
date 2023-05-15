import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationAndCameraPermissions() async {
  bool granted = false;
  
  final List<Permission> permissions = [
    Permission.location,
    Permission.camera,
  ];

  Map<Permission, PermissionStatus> permissionStatuses = await permissions.request();

  if (permissionStatuses[Permission.location]!.isGranted &&
      permissionStatuses[Permission.camera]!.isGranted) {
    granted = true;
  }

  return granted;
}


